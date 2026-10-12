// Reviews and proofreads with Gemini Nano, the model built into Chrome, so
// nothing leaves the machine. Both of Chrome's APIs for it are optional:
//
// - The Prompt API (https://developer.chrome.com/docs/ai/prompt-api) reviews
//   the local checks' findings for a paragraph (dropping false positives and
//   choosing the best fix) and finds errors they missed.
// - The Proofreader API (https://developer.chrome.com/docs/ai/proofreader-api),
//   used when the Prompt API isn't available, only finds errors.
//
// Where neither is available, this does nothing.

const LANGUAGES = { expectedInputLanguages: [ "en" ] }
const PROMPT_OPTIONS = { expectedInputs: [ { type: "text", languages: [ "en" ] } ], expectedOutputs: [ { type: "text", languages: [ "en" ] } ] }

const SYSTEM_PROMPT = `You are a careful copy editor proofreading a blog post,
one paragraph at a time. An automated grammar checker has already flagged some
possible problems in each paragraph, but it makes mistakes.

Respect the author's casual, conversational voice: informal phrasing,
contractions, sentence fragments used for effect, and stylistic choices are
not errors. Always use straight quotes and apostrophes.

For each finding from the checker, decide whether it is a genuine error. If it
is, choose the best correction for the flagged text: one of the checker's
suggestions, or a better one. Then list any genuine spelling, grammar, or
punctuation errors the checker missed, quoting the exact text from the
paragraph that is wrong.

Some paragraphs are code blocks, which the checker skips. In code, only flag
typos in comments, strings, and names, and code that is clearly wrong (like a
misspelled method or an incorrect result in a comment). Don't flag style.`

const SCHEMA = {
  type: "object",
  properties: {
    reviews: {
      type: "array",
      items: {
        type: "object",
        properties: {
          id: { type: "integer" },
          genuine: { type: "boolean" },
          correction: { type: [ "string", "null" ] }
        },
        required: [ "id", "genuine" ]
      }
    },
    missed: {
      type: "array",
      items: {
        type: "object",
        properties: {
          original: { type: "string" },
          correction: { type: "string" },
          explanation: { type: "string" }
        },
        required: [ "original", "correction", "explanation" ]
      }
    }
  },
  required: [ "reviews", "missed" ]
}

const cache = new Map() // paragraph + findings -> Promise of a review
let prompt = null // a Prompt API session
let proofreader = null // a Proofreader API session

async function status(api, options) {
  if (!api) return "unavailable"
  try {
    return await api.availability(options)
  } catch (e) {
    return "unavailable"
  }
}

// Which APIs can be used, and whether the model still needs to be downloaded
// (which requires a click to start).
export async function availability() {
  const promptStatus = await status(globalThis.LanguageModel, PROMPT_OPTIONS)
  const proofreaderStatus = await status(globalThis.Proofreader, LANGUAGES)
  const api = promptStatus !== "unavailable" ? "prompt" : (proofreaderStatus !== "unavailable" ? "proofreader" : null)
  return { api, status: api === "prompt" ? promptStatus : proofreaderStatus }
}

// Creates a session, downloading the model if needed. Must be called from a
// click when the model needs downloading.
export async function start(onProgress) {
  const { api } = await availability()
  const monitor = (m) => m.addEventListener("downloadprogress", (e) => onProgress?.(e.loaded))
  if (api === "prompt") {
    prompt ||= LanguageModel.create({ ...PROMPT_OPTIONS, initialPrompts: [ { role: "system", content: SYSTEM_PROMPT } ], monitor })
  } else if (api === "proofreader") {
    proofreader ||= Proofreader.create({ ...LANGUAGES, includeCorrectionExplanations: true, monitor })
  }
  await (prompt || proofreader)
}

export function enabled() {
  return Boolean(prompt || proofreader)
}

// Whether findings are reviewed (or only added to).
export function reviews() {
  return Boolean(prompt)
}

// Reviews a paragraph (or code block) and the local checks' findings in it,
// given as [{ id, problem, message, suggestions }]. Returns
//   { verdicts: Map(id -> { genuine, correction }),
//     missed: [{ start, end, correction, explanation }] }
// with offsets within the paragraph. Results are cached.
export function review(paragraph, code, findings) {
  // Only the Prompt API can check code.
  if (!enabled() || !paragraph.trim() || (code && !prompt)) return Promise.resolve({ verdicts: new Map(), missed: [] })
  const cacheKey = JSON.stringify([ paragraph, code, findings ])
  if (!cache.has(cacheKey)) {
    cache.set(cacheKey, run(paragraph, code, findings).catch((error) => {
      console.warn("Gemini Nano review failed", error)
      return { verdicts: new Map(), missed: [] }
    }))
  }
  return cache.get(cacheKey)
}

async function run(paragraph, code, findings) {
  if (!prompt) {
    const result = await (await proofreader).proofread(paragraph)
    return {
      verdicts: new Map(),
      missed: result.corrections.map((c) => ({
        start: c.startIndex,
        end: c.endIndex,
        correction: c.correction,
        explanation: c.explanation || "Suggested by Gemini Nano."
      }))
    }
  }

  const session = await (await prompt).clone()
  try {
    const response = await session.prompt(
      code
        ? `CODE BLOCK:\n${paragraph}\n\nFINDINGS:\n[]`
        : `PARAGRAPH:\n${paragraph}\n\nFINDINGS:\n${JSON.stringify(findings)}`,
      { responseConstraint: SCHEMA }
    )
    const { reviews, missed } = JSON.parse(response)
    return {
      verdicts: new Map(reviews.map(({ id, genuine, correction }) => [ id, { genuine, correction: correction ?? null } ])),
      missed: missed.flatMap(({ original, correction, explanation }) => {
        const start = original ? paragraph.indexOf(original) : -1
        if (start === -1 || original === correction) return []
        return [ { start, end: start + original.length, correction, explanation } ]
      })
    }
  } finally {
    session.destroy()
  }
}
