const TOKEN = /\w+|\s+|[^\w\s]/g

// A word-level diff of two strings: [[type, text]] with type "equal",
// "delete", or "insert". Deletions come before insertions, and adjacent
// changes of the same type are merged.
export function diffWords(from, to) {
  const a = from.match(TOKEN) || []
  const b = to.match(TOKEN) || []
  const lengths = Array.from({ length: a.length + 1 }, () => new Array(b.length + 1).fill(0))
  for (let i = a.length - 1; i >= 0; i--) {
    for (let j = b.length - 1; j >= 0; j--) {
      lengths[i][j] = a[i] === b[j] ? lengths[i + 1][j + 1] + 1 : Math.max(lengths[i + 1][j], lengths[i][j + 1])
    }
  }

  const changes = []
  const push = (type, text) => {
    const last = changes[changes.length - 1]
    if (last && last[0] === type) last[1] += text
    else changes.push([ type, text ])
  }
  let i = 0
  let j = 0
  while (i < a.length || j < b.length) {
    if (i < a.length && j < b.length && a[i] === b[j]) {
      push("equal", a[i++]); j++
    } else if (i < a.length && (j >= b.length || lengths[i + 1][j] >= lengths[i][j + 1])) {
      push("delete", a[i++])
    } else {
      push("insert", b[j++])
    }
  }
  return changes
}

// The minimal edits that turn `from` into `to`: [{ start, end, text }] in
// `from`'s offsets, where the text between start and end becomes `text`.
export function textEdits(from, to) {
  const edits = []
  let offset = 0
  let edit = null
  for (const [ type, text ] of diffWords(from, to)) {
    if (type === "equal") {
      edit = null
      offset += text.length
      continue
    }
    if (!edit) {
      edit = { start: offset, end: offset, text: "" }
      edits.push(edit)
    }
    if (type === "delete") {
      edit.end += text.length
      offset += text.length
    } else {
      edit.text += text
    }
  }
  return edits
}
