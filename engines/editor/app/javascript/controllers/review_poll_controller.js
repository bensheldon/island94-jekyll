import { Controller } from "@hotwired/stimulus"

// While AI reviews are running in the background, poll for their status and any
// new highlights. Each response replaces this element, which reconnects the
// controller and schedules the next poll until nothing is pending.
export default class extends Controller {
  static values = {
    url: String,
    pending: Boolean,
    interval: { type: Number, default: 1500 }
  }

  connect() {
    if (this.pendingValue) this.timer = setTimeout(() => this.poll(), this.intervalValue)
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  async poll() {
    const url = new URL(this.urlValue, window.location.href)
    url.searchParams.set("after", this.latestHighlightId())
    try {
      const response = await fetch(url, { headers: { Accept: "text/vnd.turbo-stream.html" } })
      if (response.ok) return Turbo.renderStreamMessage(await response.text())
    } catch (e) {
      // The server may be restarting; try again shortly.
    }
    this.timer = setTimeout(() => this.poll(), this.intervalValue * 2)
  }

  latestHighlightId() {
    const ids = Array.from(document.querySelectorAll("[data-highlight-id]"), (card) => Number(card.dataset.highlightId))
    return Math.max(0, ...ids)
  }
}
