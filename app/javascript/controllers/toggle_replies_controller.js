import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "label"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")

    let text = this.contentTarget.classList.contains("hidden") ? "View replies" : "Hide replies";
    this.labelTarget.textContent = text;
  }
}
