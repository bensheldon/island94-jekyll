import { Controller } from "@hotwired/stimulus"

// Draws review findings as squiggly underlines in an overlay on top of the live
// Lexxy editor instead of wrapping text in <mark> nodes (Lexical owns the contenteditable DOM and would
// strip foreign nodes). Everything recomputes as the author types, scrolls, or
// resizes.
//
// The findings are read from the commentary cards in the sidebar, so cards
// streamed in by background reviews are drawn automatically.
//
// Each finding is anchored to a span of the editor's text. As the author edits,
// the anchors are carried through each change (growing or shrinking with edits
// inside them) and the finding's quote is updated on the server, so a finding
// stays attached to the text it was about. It only goes stale when its whole
// span is deleted.
export default class extends Controller {
  static targets = ["shell", "overlay", "sidebar"]

  connect() {
    this.anchors = new Map()
    this.extending = new Set() // anchors whose text is being typed over
    this.text = null
    this.activeId = null
    this.saveTimers = new Map()
    this.boundRender = this.scheduleRender.bind(this)

    // Lexxy loads its content asynchronously, so redraw whenever its DOM changes.
    this.observer = new MutationObserver(this.boundRender)
    const lexxy = this.element.querySelector("lexxy-editor")
    if (lexxy) this.observer.observe(lexxy, { childList: true, subtree: true, characterData: true })
    if (this.hasSidebarTarget) this.observer.observe(this.sidebarTarget, { childList: true })
    window.addEventListener("resize", this.boundRender)
    window.addEventListener("scroll", this.boundRender, true)
    this.render()
  }

  disconnect() {
    this.observer.disconnect()
    window.removeEventListener("resize", this.boundRender)
    window.removeEventListener("scroll", this.boundRender, true)
  }

  get editor() {
    return this.element.querySelector("lexxy-editor [contenteditable='true']")
  }

  get cards() {
    return this.hasSidebarTarget ? Array.from(this.sidebarTarget.querySelectorAll("[data-anchor-id]")) : []
  }

  // --- Rendering ---------------------------------------------------------------

  scheduleRender() {
    cancelAnimationFrame(this._raf)
    this._raf = requestAnimationFrame(() => this.render())
  }

  render() {
    const editor = this.editor
    if (!editor || !this.hasOverlayTarget) return

    const { text, nodes } = this.textOf(editor)
    if (this.text !== null && text !== this.text) this.carryAnchors(this.text, text)
    this.text = text

    this.overlayTarget.replaceChildren()
    const shellRect = this.shellTarget.getBoundingClientRect()
    const positions = new Map()
    const drawn = [] // open anchors already underlined, to stack overlapping squiggles

    this.cards.forEach((card) => {
      const found = this.anchorFor(card, text)
      const anchor = found && this.trimmed(found, text)
      const located = anchor && anchor.end > anchor.start
      card.classList.toggle("is-stale", !located)
      if (!located) return

      positions.set(card.dataset.anchorId, anchor.start)
      this.syncQuote(card, text.slice(anchor.start, anchor.end))
      if (card.dataset.status !== "open") return

      const layer = drawn.filter((other) => other.start < anchor.end && anchor.start < other.end).length
      drawn.push(anchor)
      const active = card.dataset.anchorId === this.activeId
      const range = this.rangeFor(nodes, anchor)
      for (const rect of this.lineRects(range)) {
        if (active) this.drawBox("hl-active", rect, shellRect, rect.top, rect.height)
        this.drawBox(`hl-squiggle hl-${card.dataset.color}${active ? " is-active" : ""}`, rect, shellRect, rect.bottom - 3 + layer * 6, 7)
      }
    })

    this.reorderCards(positions)
  }

  // A range's client rects, merged into one rect per line. A span covering
  // several text nodes (e.g. a link) otherwise yields several rects per line,
  // which would break up its underline.
  lineRects(range) {
    const lines = []
    for (const rect of range.getClientRects()) {
      if (rect.width === 0) continue
      const line = lines.find((other) => Math.abs(other.bottom - rect.bottom) < 4)
      if (line) {
        line.left = Math.min(line.left, rect.left)
        line.right = Math.max(line.right, rect.right)
        line.top = Math.min(line.top, rect.top)
      } else {
        lines.push({ left: rect.left, right: rect.right, top: rect.top, bottom: rect.bottom })
      }
    }
    return lines.map((line) => ({ ...line, width: line.right - line.left, height: line.bottom - line.top }))
  }

  drawBox(className, rect, shellRect, top, height) {
    const box = document.createElement("div")
    box.className = className
    box.style.left = `${rect.left - shellRect.left}px`
    box.style.top = `${top - shellRect.top}px`
    box.style.width = `${rect.width}px`
    box.style.height = `${height}px`
    this.overlayTarget.appendChild(box)
  }

  // Keep the sidebar cards in the order their text appears in the document.
  // Stale cards keep their relative order at the end.
  reorderCards(positions) {
    const cards = this.cards
    if (cards.length < 2) return

    const rank = (card) => positions.get(card.dataset.anchorId) ?? Number.MAX_SAFE_INTEGER
    const sorted = [ ...cards ].sort((a, b) => rank(a) - rank(b))
    if (sorted.some((card, i) => card !== cards[i])) sorted.forEach((card) => this.sidebarTarget.appendChild(card))
  }

  // --- Anchoring ---------------------------------------------------------------

  // The current anchor for a card, locating its quote in the text if the anchor
  // isn't known yet (e.g. on page load, or for a newly arrived finding).
  anchorFor(card, text) {
    const id = card.dataset.anchorId
    const anchor = this.anchors.get(id)
    if (anchor && anchor.end > anchor.start) return anchor

    const located = locateQuote(text, card.dataset.quote)
    if (!located) return anchor // stale: its text was deleted

    this.anchors.set(id, located)
    return located
  }

  // Maps every anchor through the edit that turned oldText into newText. The
  // edit is the span between their common prefix and common suffix.
  carryAnchors(oldText, newText) {
    let prefix = 0
    const shortest = Math.min(oldText.length, newText.length)
    while (prefix < shortest && oldText[prefix] === newText[prefix]) prefix++
    let suffix = 0
    while (suffix < shortest - prefix && oldText[oldText.length - 1 - suffix] === newText[newText.length - 1 - suffix]) suffix++

    const oldEnd = oldText.length - suffix
    const newEnd = newText.length - suffix
    const delta = newText.length - oldText.length
    const insertion = prefix === oldEnd

    const extending = new Set()
    this.anchors.forEach((anchor) => {
      if (insertion) {
        // Text typed inside an anchor is part of the finding, as is text typed
        // while continuing to type over it. Otherwise text typed at its edges isn't.
        const continuing = anchor.end === prefix && this.extending.has(anchor)
        if (anchor.start >= prefix && !(continuing && anchor.start === prefix)) anchor.start += delta
        if (anchor.end > prefix || continuing) {
          anchor.end += delta
          if (continuing) extending.add(anchor)
        }
      } else {
        // Text replaced or deleted inside an anchor stays part of the finding.
        anchor.start = anchor.start <= prefix ? anchor.start : (anchor.start >= oldEnd ? anchor.start + delta : prefix)
        if (anchor.end > prefix && anchor.end <= oldEnd) {
          anchor.end = newEnd
          extending.add(anchor)
        } else if (anchor.end > oldEnd) {
          anchor.end += delta
        }
      }
    })
    this.extending = extending
  }

  // An anchor without surrounding whitespace.
  trimmed({ start, end }, text) {
    while (start < end && /\s/.test(text[start])) start++
    while (end > start && /\s/.test(text[end - 1])) end--
    return { start, end }
  }

  // Saves a finding's quote after its text has been edited.
  syncQuote(card, quote) {
    if (card.dataset.quote === quote) return

    card.dataset.quote = quote
    const display = card.querySelector(".commentary-quote")
    if (display) display.textContent = quote

    clearTimeout(this.saveTimers.get(card.dataset.anchorId))
    this.saveTimers.set(card.dataset.anchorId, setTimeout(() => {
      fetch(card.dataset.updateUrl, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: new URLSearchParams({ "highlight[quote]": card.dataset.quote })
      })
    }, 800))
  }

  // --- Text <-> DOM ------------------------------------------------------------

  textOf(root) {
    const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT)
    const nodes = []
    let text = ""
    let node
    while ((node = walker.nextNode())) {
      nodes.push({ node, start: text.length })
      text += node.nodeValue
    }
    return { text, nodes }
  }

  rangeFor(nodes, { start, end }) {
    const position = (offset) => {
      for (let i = nodes.length - 1; i >= 0; i--) {
        if (offset >= nodes[i].start) return { node: nodes[i].node, offset: Math.min(offset - nodes[i].start, nodes[i].node.length) }
      }
      return { node: nodes[0].node, offset: 0 }
    }
    const range = document.createRange()
    const from = position(start)
    const to = position(end)
    range.setStart(from.node, from.offset)
    range.setEnd(to.node, to.offset)
    return range
  }

  caretOffset(nodes) {
    const selection = window.getSelection()
    if (!selection || selection.rangeCount === 0) return null
    const { startContainer, startOffset } = selection.getRangeAt(0)
    const entry = nodes.find(({ node }) => node === startContainer)
    return entry ? entry.start + startOffset : null
  }

  // --- Accepting a suggestion -------------------------------------------------

  // Replaces the finding's text with its suggestion by editing the live editor,
  // so the change autosaves, can be undone, and other anchors follow along.
  async accept(event) {
    const card = event.target.closest("[data-anchor-id]")
    const editor = this.editor
    if (!card || !editor) return

    const { text } = this.textOf(editor)
    const found = this.anchorFor(card, text)
    if (!found) return

    const anchor = this.trimmed(found, text)
    const current = text.slice(anchor.start, anchor.end)
    // The text may have changed since the suggestion was made (e.g. by accepting
    // an overlapping suggestion), so apply the suggestion's changes to it.
    const replacement = applySuggestion(card.dataset.originalQuote, card.dataset.suggestion, current)

    this.updateCard(card, { "highlight[status]": "accepted", "highlight[quote]": replacement })
    await this.replaceText(editor, anchor.start, current, replacement)
  }

  // Edits only the words that change, so formatting (bold, links, code...) on
  // the rest of the text is kept. Edits are applied from the end backwards so
  // that earlier offsets stay valid.
  async replaceText(editor, offset, current, replacement) {
    editor.focus()
    for (const edit of textEdits(current, replacement).reverse()) {
      const { nodes } = this.textOf(editor)
      const selection = window.getSelection()
      selection.removeAllRanges()
      selection.addRange(this.rangeFor(nodes, { start: offset + edit.start, end: offset + edit.end }))
      if (edit.text) {
        document.execCommand("insertText", false, edit.text)
      } else {
        document.execCommand("delete")
      }
      // Let Lexical update the DOM before measuring the next edit.
      await new Promise((resolve) => requestAnimationFrame(resolve))
    }
  }

  async updateCard(card, params) {
    const response = await fetch(card.dataset.updateUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "text/vnd.turbo-stream.html",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: new URLSearchParams(params)
    })
    if (response.ok) Turbo.renderStreamMessage(await response.text())
  }

  // --- Activation --------------------------------------------------------------

  activateFromCaret() {
    const editor = this.editor
    if (!editor) return
    const caret = this.caretOffset(this.textOf(editor).nodes)
    if (caret === null) return

    const card = this.cards.find((card) => {
      const anchor = this.anchors.get(card.dataset.anchorId)
      return card.dataset.status === "open" && anchor && caret >= anchor.start && caret <= anchor.end
    })
    if (card) this.activate(card.dataset.anchorId)
  }

  activate(anchorId) {
    this.activeId = anchorId
    this.render()
    this.cards.forEach((card) => {
      const active = card.dataset.anchorId === anchorId
      card.classList.toggle("is-active", active)
      if (active) card.scrollIntoView({ behavior: "smooth", block: "nearest" })
    })
  }

  // Scroll the editor to a finding (called when a sidebar card is focused).
  scrollToHighlight(anchorId) {
    const editor = this.editor
    const anchor = this.anchors.get(anchorId)
    if (!editor || !anchor || anchor.end <= anchor.start) return
    const rect = this.rangeFor(this.textOf(editor).nodes, anchor).getClientRects()[0]
    if (rect) window.scrollTo({ top: window.scrollY + rect.top - 120, behavior: "smooth" })
  }
}

// --- Locating quotes --------------------------------------------------------

// Finds a quote in the editor's text. The server's text has newlines between
// paragraphs and at line breaks, but the editor's text nodes are concatenated
// without separators, so any whitespace in the quote may match none or more.
function locateQuote(text, quote) {
  if (!quote) return null
  const start = text.indexOf(quote)
  if (start !== -1) return { start, end: start + quote.length }

  const words = quote.trim().split(/\s+/).map((word) => word.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"))
  const match = new RegExp(words.join("\\s*")).exec(text)
  return match ? { start: match.index, end: match.index + match[0].length } : null
}

// --- Applying a suggestion -------------------------------------------------

const TOKEN = /\w+|\s+|[^\w\s]/g

// A word-level diff of two strings: [[type, text]] with type "equal", "delete", or "insert".
function diffWords(from, to) {
  const a = from.match(TOKEN) || []
  const b = to.match(TOKEN) || []
  const lengths = Array.from({ length: a.length + 1 }, () => new Array(b.length + 1).fill(0))
  for (let i = a.length - 1; i >= 0; i--) {
    for (let j = b.length - 1; j >= 0; j--) {
      lengths[i][j] = a[i] === b[j] ? lengths[i + 1][j + 1] + 1 : Math.max(lengths[i + 1][j], lengths[i][j + 1])
    }
  }
  const changes = []
  let i = 0
  let j = 0
  while (i < a.length || j < b.length) {
    if (i < a.length && j < b.length && a[i] === b[j]) {
      changes.push([ "equal", a[i++] ]); j++
    } else if (i < a.length && (j >= b.length || lengths[i + 1][j] >= lengths[i][j + 1])) {
      changes.push([ "delete", a[i++] ])
    } else {
      changes.push([ "insert", b[j++] ])
    }
  }
  return changes
}

// The minimal edits that turn `from` into `to`: [{ start, end, text }] in
// `from`'s offsets, where the text between start and end becomes `text`.
function textEdits(from, to) {
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

// Applies the changes that turn `original` into `suggestion` onto `current`,
// a version of `original` that may since have been edited. Changes that no
// longer apply are skipped, and the rest of `current` is kept.
export function applySuggestion(original, suggestion, current) {
  if (current === original) return suggestion
  if (current === suggestion) return current

  let result = ""
  let position = 0
  for (const [ type, text ] of diffWords(original, suggestion)) {
    if (type === "equal") {
      const index = current.indexOf(text, position)
      if (index === -1) continue
      result += current.slice(position, index + text.length)
      position = index + text.length
    } else if (type === "delete") {
      if (current.startsWith(text, position)) position += text.length
    } else if (current.startsWith(text, position)) {
      result += text // already inserted
      position += text.length
    } else {
      result += text
    }
  }
  return result + current.slice(position)
}
