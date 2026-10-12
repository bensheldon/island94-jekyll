// Proofreads with Gemini Nano, the model built into Chrome, so nothing leaves
// the machine. Uses Chrome's Proofreader API where it's available, and
// otherwise the Prompt API. Both are optional: where neither is available,
// this does nothing.
//
// https://developer.chrome.com/docs/ai/proofreader-api
// https://developer.chrome.com/docs/ai/prompt-api

const OPTIONS = { expectedInputLanguages: [ "en" ] }

const PROMPT = `You are a careful copy editor proofreading a paragraph from a blog
post. Find genuine errors only: spelling, grammar, punctuation, and words used
incorrectly. Respect the author's casual voice: do not flag informal phrasing,
contractions, or deliberate sentence fragments. Always use straight quotes and
apostrophes. For each error, give the exact text from the paragraph that is
wrong, the smallest correction, and a short explanation. If there are no
errors, return an empty list.`

const SCHEMA = {
  type: "object",
  properties: {
    corrections: {
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
  required: [ "corrections" ]
}

const cache = new Map() // paragraph text -> Promise of corrections
let session = null

// Which API is usable: "proofreader", "prompt", or null. And whether the model
// still needs to be downloaded (which requires a click to start).
export async function availability() {
  for (const [ api, name ] of [ [ globalThis.Proofreader, "proofreader" ], [ globalThis.LanguageModel, "prompt" ] ]) {
    if (!api) continue
    try {
      const status = await api.availability(name === "prompt" ? { expectedInputs: [ { type: "text", languages: [ "en" ] } ] } : OPTIONS)
      if (status !== "unavailable") return { api: name, status }
    } catch (e) {
      // Try the next API.
    }
  }
  return { api: null, status: "unavailable" }
}

// Creates the session, downloading the model if needed. Must be called from a
// click when the model needs downloading.
export async function start(onProgress) {
  const { api } = await availability()
  if (!api) return null

  const monitor = (m) => m.addEventListener("downloadprogress", (e) => onProgress?.(e.loaded))
  session ||= api === "proofreader"
    ? Proofreader.create({ ...OPTIONS, includeCorrectionExplanations: true, monitor })
    : LanguageModel.create({ initialPrompts: [ { role: "system", content: PROMPT } ], monitor })
  return session
}

// Whether a Gemini Nano session has been started.
export function enabled() {
  return session !== null
}

// Proofreads a paragraph, returning [{ start, end, correction, explanation }]
// with offsets within the paragraph. Results are cached by paragraph text.
export function proofread(paragraph) {
  if (!session || !paragraph.trim()) return Promise.resolve([])
  if (!cache.has(paragraph)) cache.set(paragraph, run(paragraph).catch(() => []))
  return cache.get(paragraph)
}

async function run(paragraph) {
  const instance = await session
  if (globalThis.Proofreader && instance instanceof Proofreader) {
    const result = await instance.proofread(paragraph)
    return result.corrections.map((c) => ({
      start: c.startIndex,
      end: c.endIndex,
      correction: c.correction,
      explanation: c.explanation || "Suggested by Gemini Nano."
    }))
  }

  const response = await instance.clone().then((clone) => clone.prompt(paragraph, { responseConstraint: SCHEMA }))
  return JSON.parse(response).corrections.flatMap(({ original, correction, explanation }) => {
    const start = paragraph.indexOf(original)
    if (!original || start === -1 || original === correction) return []
    return [ { start, end: start + original.length, correction, explanation } ]
  })
}
