// Lints text locally with Harper (https://writewithharper.com), a grammar
// checker compiled to WebAssembly, supplemented by pattern-based rules. Runs in
// a Web Worker so linting never blocks typing.
import { WorkerLinter } from "harper.js"
import { binary } from "harper.js/binary"
import { runCustomRules, COMMON_MISSPELLINGS } from "./custom_rules"

let linter = null

function harper() {
  linter ||= (async () => {
    const instance = new WorkerLinter({ binary })
    await instance.setup()
    return instance
  })()
  return linter
}

const SUGGESTION_KINDS = [ "ReplaceWith", "Remove", "InsertAfter" ]

// Lints `text`, returning findings as
// { start, end, problem, message, rule, category, suggestions: [text], source }
// where suggestions are replacements for text.slice(start, end).
export async function lint(text) {
  const lints = await (await harper()).lint(text, { language: "plaintext" })
  const offsets = utf16Offsets(text)
  const serialized = lints.map((lint) => {
    const span = lint.span()
    const lintKind = lint.lint_kind()
    const suggestions = lint.suggestions()
    const result = {
      span: { start: offsets(span.start), end: offsets(span.end) },
      message: lint.message(),
      lintKind,
      lintKindPretty: lint.lint_kind_pretty(),
      category: categorize(lintKind),
      problemText: lint.get_problem_text(),
      suggestions: suggestions.map((suggestion) => ({
        text: suggestion.get_replacement_text(),
        kind: SUGGESTION_KINDS[suggestion.kind()] ?? "ReplaceWith"
      }))
    }
    // Free the WebAssembly objects.
    span.free()
    suggestions.forEach((suggestion) => suggestion.free())
    lint.free()
    return result
  })

  const harperLints = fixHarperSuggestions(serialized, text)
  return [ ...harperLints, ...runCustomRules(text, harperLints) ]
    .sort((a, b) => a.span.start - b.span.start)
    .map((lint) => toFinding(lint, text, "harper"))
}

function toFinding(lint, text, source) {
  const { start, end } = lint.span
  const problem = text.slice(start, end)
  const suggestions = lint.suggestions.map(({ text: replacement, kind }) => {
    if (kind === "Remove") return ""
    if (kind === "InsertAfter") return problem + replacement
    return replacement
  })
  return {
    start,
    end,
    problem,
    message: lint.message,
    rule: lint.lintKindPretty,
    category: lint.category,
    suggestions: [ ...new Set(suggestions) ].filter((suggestion) => suggestion !== problem),
    source
  }
}

// Harper's spans count Unicode code points; JavaScript strings index UTF-16
// code units. Returns a function converting the former to the latter.
function utf16Offsets(text) {
  if (!/[\uD800-\uDFFF]/.test(text)) return (offset) => offset

  const map = []
  let index = 0
  for (const character of text) {
    map.push(index)
    index += character.length
  }
  map.push(index)
  return (offset) => map[offset] ?? index
}

// --- Ported from writing-helper by Ravi Gadgil (MIT License) ----------------
// https://github.com/ravigadgil/writing-helper/blob/main/src/background/service-worker.js
// See custom_rules.js for the license.

/**
 * Post-process Harper lints to fix bad suggestions.
 *
 * Harper's SplitWords rule sometimes splits misspelled words nonsensically
 * (e.g. "writting" → "writ ting" instead of "writing").
 * If the original word is a known misspelling, replace the suggestion.
 * If the suggestion introduces a space but the original had none, and
 * it's not a real compound word split, drop the bad suggestion.
 */
function fixHarperSuggestions(lints, text) {
  for (const lint of lints) {
    const problem = lint.problemText?.toLowerCase();
    if (!problem) continue;

    // Check if it's a known misspelling we can correct
    const knownFix = COMMON_MISSPELLINGS[problem];
    if (knownFix) {
      // Replace all suggestions with the correct one
      lint.suggestions = [{ text: knownFix, kind: 'ReplaceWith' }];
      lint.message = `Did you mean "${knownFix}"?`;
      continue;
    }

    // Filter out bad split-word suggestions: if original has no space
    // but the suggestion introduces one, it's likely a bad split
    if (!problem.includes(' ')) {
      lint.suggestions = lint.suggestions.filter(s => {
        const sugText = s.text;
        // If suggestion has a space, check if it's a plausible word split
        if (sugText.includes(' ')) {
          const parts = sugText.split(/\s+/);
          // Allow splits where parts are common short words (prepositions, articles, etc.)
          const commonShortWords = new Set([
            'a', 'an', 'am', 'as', 'at', 'be', 'by', 'do', 'go', 'he', 'if',
            'in', 'is', 'it', 'me', 'my', 'no', 'of', 'on', 'or', 'so', 'to',
            'up', 'us', 'we', 'id', 'ok',
          ]);
          const allPartsValid = parts.every(p => p.length >= 3 || commonShortWords.has(p.toLowerCase()));
          if (!allPartsValid) return false;
          // Also drop if the combined parts look like a misspelling variant
          // (the original word minus/plus a letter → not a real split)
          // But only if no part is a common short word (real splits like "testof" → "test of" are valid)
          const hasCommonWord = parts.some(p => commonShortWords.has(p.toLowerCase()));
          if (!hasCommonWord) {
            const combined = parts.join('');
            if (Math.abs(combined.length - problem.length) <= 1) return false;
          }
        }
        return true;
      });

      // If all suggestions got filtered out and it's a spelling/typo lint,
      // try to generate a basic suggestion by removing doubled letters
      if (lint.suggestions.length === 0 &&
          (lint.lintKind === 'Spelling' || lint.lintKind === 'Typo')) {
        const fixed = fixDoubledLetters(problem);
        if (fixed && fixed !== problem) {
          lint.suggestions = [{ text: matchCase(fixed, lint.problemText), kind: 'ReplaceWith' }];
          lint.message = `Did you mean "${matchCase(fixed, lint.problemText)}"?`;
        }
      }
    }
  }

  // Remove lints that have no suggestions and are just SplitWords noise
  return lints.filter(l => {
    if (l.suggestions.length === 0 &&
        (l.lintKind === 'Spelling' || l.lintKind === 'Typo')) {
      // Keep it — still shows the underline, user just won't get a fix suggestion
      // Actually, let's keep these so the error is still shown
      return true;
    }
    return true;
  });
}

/**
 * Fix common doubled-letter misspellings by trying single-consonant
 * de-duplication one pair at a time. Only returns a candidate if it's
 * in the COMMON_MISSPELLINGS table — avoids mangling real words like
 * "butter", "happy", "tapping".
 */
function fixDoubledLetters(word) {
  // First check if the whole word (with all doubles removed) is known
  const knownFix = COMMON_MISSPELLINGS[word];
  if (knownFix) return knownFix;

  // Try removing one doubled consonant at a time
  const doublePattern = /([bcdfghjklmnpqrstvwxyz])\1/g;
  let match;
  while ((match = doublePattern.exec(word)) !== null) {
    const candidate = word.substring(0, match.index) + match[1] + word.substring(match.index + 2);
    const knownCandidate = COMMON_MISSPELLINGS[candidate];
    if (knownCandidate) return knownCandidate;
  }

  return null;
}

/** Preserve the case pattern of the original when applying a fix */
function matchCase(fixed, original) {
  if (!original || !fixed) return fixed;
  if (original === original.toUpperCase()) return fixed.toUpperCase();
  if (original[0] === original[0].toUpperCase()) {
    return fixed[0].toUpperCase() + fixed.slice(1);
  }
  return fixed;
}

/**
 * Map Harper's 20 lintKind values into 3 visual categories:
 *  - 'spelling' → red underline (misspelled words)
 *  - 'grammar'  → blue underline (grammar, agreement, punctuation, etc.)
 *  - 'style'    → amber/yellow underline (suggestions, readability, enhancement)
 */
function categorize(lintKind) {
  switch (lintKind) {
    case 'Spelling':
    case 'Typo':
      return 'spelling';
    case 'Enhancement':
    case 'Readability':
    case 'Style':
    case 'Redundancy':
    case 'WordChoice':
    case 'Repetition':
      return 'style';
    default:
      // Agreement, Grammar, Punctuation, Capitalization, Miscellaneous,
      // BoundaryError, Eggcorn, Malapropism, Nonstandard, Regionalism,
      // Usage, Formatting
      return 'grammar';
  }
}
