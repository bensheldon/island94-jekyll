import { Controller } from "@hotwired/stimulus"

// Tick forward and back through the open suggestions (highlighted spans +
// their commentary). Keeps the document mark, the sidebar card, and a small
// "3 of 12" counter in sync.
export default class extends Controller {
  static targets = ["counter", "card"]
  static outlets = ["annotations"]

  connect() {
    this.index = -1
    this.updateCounter()
  }

  next() { this.move(1) }
  previous() { this.move(-1) }

  move(delta) {
    const cards = this.openCards()
    if (cards.length === 0) return

    this.index = (this.index + delta + cards.length) % cards.length
    const card = cards[this.index]
    this.select(card)
  }

  // Jump straight to a card that was clicked.
  focusCard(event) {
    const card = event.currentTarget.closest("[data-anchor-id]")
    if (!card) return
    const cards = this.openCards()
    this.index = cards.indexOf(card)
    this.select(card)
  }

  select(card) {
    const anchorId = card.dataset.anchorId
    if (this.hasAnnotationsOutlet) {
      this.annotationsOutlet.activate(anchorId)
      this.annotationsOutlet.scrollToHighlight(anchorId)
    }
    this.updateCounter()
  }

  openCards() {
    return this.cardTargets.filter((c) => c.dataset.status === "open" && !c.classList.contains("is-stale"))
  }

  updateCounter() {
    if (!this.hasCounterTarget) return
    const total = this.openCards().length
    const current = this.index >= 0 ? this.index + 1 : 0
    this.counterTarget.textContent = total === 0 ? "No open suggestions" : `${current} of ${total}`
  }

  // Called after a turbo_stream mutates the list.
  cardTargetConnected() { this.updateCounter() }
  cardTargetDisconnected() {
    if (this.index >= this.openCards().length) this.index = this.openCards().length - 1
    this.updateCounter()
  }
}
