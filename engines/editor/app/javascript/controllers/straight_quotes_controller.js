import { Controller } from "@hotwired/stimulus"

// The blog always uses straight quotes and apostrophes. Replaces curly ones as
// they're typed into the editor (e.g. by macOS smart quotes). Pasted text is
// straightened when it's saved.
export default class extends Controller {
  connect() {
    this.boundBeforeInput = this.beforeInput.bind(this)
    this.element.addEventListener("beforeinput", this.boundBeforeInput, true)
  }

  disconnect() {
    this.element.removeEventListener("beforeinput", this.boundBeforeInput, true)
  }

  beforeInput(event) {
    if (!["insertText", "insertReplacementText"].includes(event.inputType)) return
    const text = event.data ?? event.dataTransfer?.getData("text/plain")
    if (!text || !/[‘’“”]/.test(text)) return

    event.preventDefault()
    event.stopImmediatePropagation()
    document.execCommand("insertText", false, text.replace(/[‘’]/g, "'").replace(/[“”]/g, '"'))
  }
}
