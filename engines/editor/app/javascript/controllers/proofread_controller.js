import { Controller } from "@hotwired/stimulus"
import { lint } from "../proofreading/linter"
import * as gemini from "../proofreading/gemini"
import { textEdits } from "../proofreading/diff"

// Proofreads the post as it's edited, entirely in the browser: Harper and
// pattern rules (instant), then Gemini Nano in Chrome (slower, per paragraph).
//
// Each new set of findings is sent to the server, which stores them and renders
// the sidebar's cards (where they can be accepted or ignored). The findings are
// drawn as squiggly underlines from those cards, in an overlay on top of the
// Lexxy editor (Lexical owns the contenteditable DOM, so we can't add markup).
export default class extends Controller {
  static targets = [ "shell", "overlay", "sidebar", "counter", "gemini" ]
  static values = {
    findingsUrl: String,
    delay: { type: Number, default: 400 }
  }

  connect() {
    this.version = 0
    this.current = false // whether the cards' positions match the current text
    this.activeId = null
    this.sending = Promise.resolve()
    this.boundChanged = this.changed.bind(this)
    this.boundRender = () => requestAnimationFrame(() => this.render())

    // Lexxy loads its content asynchronously, so start whenever its DOM changes.
    this.observer = new MutationObserver(this.boundChanged)
    this.observer.observe(this.lexxy, { childList: true, subtree: true, characterData: true })
    // Redraw whenever the server sends new cards.
    this.cardsObserver = new MutationObserver(this.boundRender)
    this.cardsObserver.observe(this.sidebarTarget, { childList: true, subtree: true })
    window.addEventListener("resize", this.boundRender)
    window.addEventListener("scroll", this.boundRender, true)

    this.updateGeminiStatus()
    this.changed()
  }

  disconnect() {
    this.observer.disconnect()
    this.cardsObserver.disconnect()
    window.removeEventListener("resize", this.boundRender)
    window.removeEventListener("scroll", this.boundRender, true)
    clearTimeout(this.timer)
  }

  get lexxy() {
    return this.element.querySelector("lexxy-editor")
  }

  get editor() {
    return this.element.querySelector("lexxy-editor [contenteditable='true']")
  }

  // The findings shown in the sidebar, as rendered by the server (not
  // counting those Gemini Nano dismissed).
  get cards() {
    return Array.from(this.sidebarTarget.querySelectorAll(".commentary-card[data-key]"))
      .filter((card) => !card.closest(".dismissed-by-ai"))
  }

  // --- Proofreading ------------------------------------------------------------

  changed() {
    // Positions are stale until the post is proofread again, so hide the
    // underlines meanwhile.
    this.version++
    this.current = false
    this.draw()
    clearTimeout(this.timer)
    this.timer = setTimeout(() => this.proofread(), this.delayValue)
  }

  async proofread() {
    const editor = this.editor
    if (!editor) return
    const version = this.version
    const extracted = extractText(editor)
    const { text } = extracted

    // Code is blanked out for the local checks; drop anything they flag in it.
    const findings = (await lint(text)).filter((finding) => !extracted.code.some((range) => overlaps(range, finding)))
    if (version !== this.version) return
    this.send("harper", findings, version)

    // Gemini Nano is slower, so it runs afterwards, paragraph by paragraph:
    // reviewing those findings, and adding any errors they missed.
    if (!gemini.enabled()) return
    const reviewed = findings.map((finding) => ({ ...finding }))
    let aiFindings = []
    for (const paragraph of paragraphs(extracted)) {
      const paragraphEnd = paragraph.start + paragraph.text.length
      const inParagraph = reviewed.filter((f) => f.start >= paragraph.start && f.end <= paragraphEnd)
      const { verdicts, missed } = await gemini.review(paragraph.text, paragraph.code, inParagraph.map((f, id) => ({
        id,
        problem: f.problem,
        message: f.message,
        suggestions: f.suggestions
      })))
      if (version !== this.version) return

      inParagraph.forEach((finding, id) => {
        const verdict = verdicts.get(id)
        if (!verdict) return
        finding.verdict = verdict.genuine ? "confirmed" : "dismissed"
        // Put Gemini's choice of correction first.
        if (verdict.genuine && verdict.correction && verdict.correction !== finding.problem) {
          finding.suggestions = [ verdict.correction, ...finding.suggestions.filter((s) => s !== verdict.correction) ]
        }
      })
      aiFindings = [
        ...aiFindings,
        ...missed
          .map((c) => aiFinding(extracted.raw, paragraph.start + c.start, paragraph.start + c.end, c, paragraph.code))
          .filter((finding) => !reviewed.some((other) => overlaps(other, finding)))
      ]
    }
    if (gemini.reviews()) this.send("harper", reviewed, version)
    this.send("ai", aiFindings, version)
  }

  // Sends findings to the server, which renders the cards. Requests are sent
  // one at a time so that responses can't arrive out of order.
  send(source, findings, version) {
    const body = JSON.stringify({ source, findings: findings.map((finding) => ({ ...finding, key: key(finding) })) })
    this.sending = this.sending.then(async () => {
      if (version !== this.version) return
      const response = await fetch(this.findingsUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body
      }).catch(() => null)
      if (!response?.ok || version !== this.version) return
      Turbo.renderStreamMessage(await response.text())
      // The cards now match the current text, so they can be drawn and used.
      this.current = true
      this.render()
    })
  }

  // --- Rendering ---------------------------------------------------------------

  render() {
    this.draw()
    const cards = this.cards
    const index = cards.findIndex((card) => card.id === this.activeId)
    cards.forEach((card) => card.classList.toggle("is-active", card.id === this.activeId))
    this.counterTarget.textContent = cards.length === 0 ? "" : `${index >= 0 ? `${index + 1} of ` : ""}${cards.length}`
  }

  draw() {
    const editor = this.editor
    if (!editor || !this.hasOverlayTarget) return
    this.overlayTarget.replaceChildren()
    if (!this.current) return

    const { segments } = extractText(editor)
    const shellRect = this.shellTarget.getBoundingClientRect()
    const drawn = []

    this.cards.forEach((card) => {
      const finding = position(card)
      const range = rangeFor(segments, finding.start, finding.end)
      if (!range) return
      const layer = drawn.filter((other) => overlaps(other, finding)).length
      drawn.push(finding)
      const active = card.id === this.activeId
      for (const rect of lineRects(range)) {
        if (active) this.drawBox("hl-active", rect, shellRect, rect.top, rect.height)
        this.drawBox(`hl-squiggle hl-${card.dataset.color}`, rect, shellRect, rect.bottom - 3 + layer * 6, 7)
      }
    })
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

  // --- Accepting a suggestion -------------------------------------------------

  // Applies a suggestion by editing the post. The finding then goes away when
  // the post is next proofread.
  async accept(event) {
    const card = event.target.closest("[data-key]")
    const { problem, suggestion } = event.currentTarget.dataset
    const { start, end } = position(card)
    // Only act on cards that match the current text, and the text it's about.
    if (!this.current || extractText(this.editor).raw.slice(start, end) !== problem) return

    // Edit only the words that change, so formatting on the rest is kept. Edits
    // go from the end backwards so that earlier offsets stay valid.
    const editor = this.editor
    editor.focus()
    for (const edit of textEdits(problem, suggestion).reverse()) {
      const { segments } = extractText(editor)
      const range = rangeFor(segments, start + edit.start, start + edit.end)
      if (!range) return
      const selection = window.getSelection()
      selection.removeAllRanges()
      selection.addRange(range)
      document.execCommand(edit.text ? "insertText" : "delete", false, edit.text)
      // Let Lexical update the DOM before measuring the next edit.
      await new Promise((resolve) => requestAnimationFrame(resolve))
    }
  }

  // --- Gemini Nano -------------------------------------------------------------

  async updateGeminiStatus() {
    const { api, status } = await gemini.availability()
    const target = this.geminiTarget
    if (!api) {
      target.textContent = "Gemini Nano isn't available in this browser."
    } else if (status === "available") {
      await gemini.start()
      target.textContent = `Gemini Nano: on (${api === "proofreader" ? "Proofreader API" : "Prompt API"})`
      this.changed()
    } else {
      target.innerHTML = `<button type="button" class="btn btn-sm btn-link p-0 align-baseline" data-action="proofread#enableGemini">Download Gemini Nano</button> to also proofread with Chrome's built-in AI.`
    }
  }

  // Downloading the model has to be started by a click.
  async enableGemini() {
    this.geminiTarget.textContent = "Gemini Nano: starting…"
    await gemini.start((loaded) => {
      this.geminiTarget.textContent = `Gemini Nano: downloading ${Math.round(loaded * 100)}%`
    })
    await this.updateGeminiStatus()
  }

  // --- Navigation --------------------------------------------------------------

  next() { this.move(1) }
  previous() { this.move(-1) }

  move(delta) {
    const cards = this.cards
    if (cards.length === 0) return
    const index = cards.findIndex((card) => card.id === this.activeId)
    const next = cards[(index + delta + cards.length) % cards.length]
    this.activate(next.id, { scroll: true })
  }

  focusCard(event) {
    this.activate(event.currentTarget.id, { scroll: true })
  }

  activateFromCaret() {
    const editor = this.editor
    const selection = window.getSelection()
    if (!editor || !this.current || !selection?.rangeCount) return
    const { segments } = extractText(editor)
    const { startContainer, startOffset } = selection.getRangeAt(0)
    const segment = segments.find(({ node }) => node === startContainer)
    if (!segment) return
    const caret = segment.start + startOffset
    const card = this.cards.find((c) => {
      const { start, end } = position(c)
      return caret >= start && caret <= end
    })
    if (card) this.activate(card.id)
  }

  // Activates a finding by its card's id (unique, unlike its key, which is
  // shared by repeated occurrences of the same problem).
  activate(cardId, { scroll = false } = {}) {
    this.activeId = cardId
    this.render()
    const card = this.cards.find((c) => c.id === cardId)
    card?.scrollIntoView({ block: "nearest" })
    if (!scroll || !card || !this.current) return
    const { start, end } = position(card)
    const rect = rangeFor(extractText(this.editor).segments, start, end)?.getClientRects()[0]
    if (rect) window.scrollTo({ top: window.scrollY + rect.top - 120, behavior: "smooth" })
  }
}

// --- Findings ------------------------------------------------------------------

// Identifies a finding across edits, so an ignored finding stays ignored.
function key(finding) {
  return `${finding.source}:${finding.rule}:${finding.problem}`
}

function position(card) {
  return { start: Number(card.dataset.start), end: Number(card.dataset.end) }
}

function overlaps(a, b) {
  return a.start < b.end && b.start < a.end
}

function aiFinding(text, start, end, { correction, explanation }, code) {
  return {
    start,
    end,
    problem: text.slice(start, end),
    message: explanation,
    rule: code ? "Code" : "Gemini Nano",
    category: "ai",
    suggestions: [ correction ],
    source: "ai"
  }
}

// --- Text <-> DOM ----------------------------------------------------------------

const BLOCKS = new Set([ "P", "H1", "H2", "H3", "H4", "H5", "H6", "LI", "PRE", "BLOCKQUOTE", "DIV", "TD", "TH", "FIGURE" ])

// The editor's text, as a proofreader should see it: paragraphs separated by
// blank lines, line breaks as newlines, and code blanked out (keeping its
// length, so offsets still line up). `raw` is the same, but with the code.
// `segments` maps offsets back to the DOM.
function extractText(root) {
  let text = ""
  let raw = ""
  const segments = []
  const code = [] // ranges of code
  const append = (value, inCode) => {
    if (inCode) code.push({ start: text.length, end: text.length + value.length })
    text += inCode ? value.replace(/[^\n]/g, " ") : value
    raw += value
  }
  const separate = () => {
    if (text && !text.endsWith("\n\n")) append(text.endsWith("\n") ? "\n" : "\n\n", false)
  }
  const walk = (node, inCode) => {
    if (node.nodeType === Node.TEXT_NODE) {
      segments.push({ node, start: text.length, length: node.length })
      append(node.nodeValue, inCode)
      return
    }
    if (node.nodeType !== Node.ELEMENT_NODE || node.getAttribute("contenteditable") === "false") return
    if (node.tagName === "BR") {
      append("\n", false)
      return
    }
    // Lexxy renders code blocks as <code data-language>.
    const block = BLOCKS.has(node.tagName) || (node.tagName === "CODE" && node.hasAttribute("data-language"))
    const isCode = inCode || node.tagName === "CODE" || node.tagName === "PRE"
    if (block) separate()
    node.childNodes.forEach((child) => walk(child, isCode))
    if (block) separate()
  }
  root.childNodes.forEach((child) => walk(child, false))
  return { text, raw, segments, code }
}

// The paragraphs of extracted text, with their offsets, including code blocks
// (which are blank in `text`, but not in `raw`).
function paragraphs({ text, raw }) {
  const result = []
  const pattern = /[^\n]+(?:\n[^\n]+)*/g
  let match
  while ((match = pattern.exec(raw))) {
    if (!match[0].trim()) continue
    const code = !text.slice(match.index, match.index + match[0].length).trim()
    result.push({ text: match[0], start: match.index, code })
  }
  return result
}

function rangeFor(segments, start, end) {
  const locate = (offset, isEnd) => {
    for (const segment of segments) {
      const segmentEnd = segment.start + segment.length
      if (offset >= segment.start && (offset < segmentEnd || (isEnd && offset === segmentEnd))) {
        return { node: segment.node, offset: offset - segment.start }
      }
      if (offset < segment.start) return { node: segment.node, offset: 0 } // in a separator
    }
    return null
  }
  const from = locate(start, false)
  const to = locate(end, true)
  if (!from || !to) return null
  const range = document.createRange()
  range.setStart(from.node, from.offset)
  range.setEnd(to.node, to.offset)
  return range
}

// A range's client rects, merged into one rect per line.
function lineRects(range) {
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
