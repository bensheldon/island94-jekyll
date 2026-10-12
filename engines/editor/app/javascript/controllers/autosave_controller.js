import { Controller } from "@hotwired/stimulus"

// Debounced silent save of the editor form back to the post's file. Does not
// create revisions.
//
// Saves are serialized so that an older save can never overwrite a newer one,
// and any other form submitted on the page (e.g. running a review) waits until
// the latest edits are saved, so it sees the current text.
export default class extends Controller {
  static targets = ["form", "status"]
  static values = {
    url: String,
    delay: { type: Number, default: 1500 }
  }

  connect() {
    this.dirty = false
    this.saving = Promise.resolve(true)
    this.boundBeforeUnload = this.beforeUnload.bind(this)
    this.boundKeydown = this.keydown.bind(this)
    window.addEventListener("beforeunload", this.boundBeforeUnload)
    document.addEventListener("keydown", this.boundKeydown)
  }

  disconnect() {
    window.removeEventListener("beforeunload", this.boundBeforeUnload)
    document.removeEventListener("keydown", this.boundKeydown)
    // Turbo navigation keeps this page's JavaScript running, so the queued save
    // still happens; keepalive lets it finish even if the page is unloaded.
    if (this.dirty) this.save({ keepalive: true })
  }

  schedule() {
    this.dirty = true
    clearTimeout(this.timer)
    this.setStatus("Editing…")
    this.timer = setTimeout(() => this.save(), this.delayValue)
  }

  // Saves the current edits after any save already in flight. Resolves to
  // whether everything is saved.
  save({ keepalive = false } = {}) {
    clearTimeout(this.timer)
    this.saving = this.saving.then(async () => {
      if (!this.dirty) return true
      this.dirty = false
      const ok = await this.request({ keepalive })
      if (!ok) this.dirty = true
      return ok
    })
    return this.saving
  }

  async request({ keepalive = false } = {}) {
    this.setStatus("Saving…")
    try {
      const response = await fetch(this.urlValue, {
        method: "POST", // the form's hidden _method field makes this a PATCH
        headers: { "X-CSRF-Token": this.csrfToken(), "Accept": "application/json" },
        body: new FormData(this.formTarget),
        keepalive
      })
      if (response.ok) {
        this.setStatus(this.dirty ? "Editing…" : "Saved")
      } else {
        const { errors } = await response.json().catch(() => ({}))
        this.setStatus(`Save failed${errors ? `: ${errors.join(", ")}` : ""}`)
      }
      return response.ok
    } catch (e) {
      this.setStatus("Offline")
      return false
    }
  }

  // Holds other forms' submissions until the latest edits are saved. The
  // editor form itself submits everything, so it only needs to wait for any
  // save already in flight.
  async guard(event) {
    const form = event.target
    if (form.dataset.autosaveReady) {
      delete form.dataset.autosaveReady
      return
    }

    event.preventDefault()
    event.stopImmediatePropagation()
    if (form === this.formTarget) {
      clearTimeout(this.timer)
      this.dirty = false
      await this.saving
    } else if (!(await this.save())) {
      return
    }
    form.dataset.autosaveReady = "true"
    // Resubmit in a new task: the browser ignores requestSubmit() while it's
    // still dispatching this submit event, which a resolved await may be.
    setTimeout(() => form.requestSubmit(event.submitter))
  }

  // ⌘S / Ctrl-S saves a revision.
  keydown(event) {
    if (event.key !== "s" || !(event.metaKey || event.ctrlKey) || event.shiftKey || event.altKey) return

    event.preventDefault()
    this.formTarget.requestSubmit()
  }

  beforeUnload(event) {
    if (this.dirty) event.preventDefault()
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content
  }
}
