import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element.querySelector("input[name='authenticity_token']") == null) {
      this.element.closest("form").appendChild(this.authenticityToken)
    }
  }

  get authenticityToken() {
    const input = document.createElement("input")

    input.type = "hidden"
    input.name = "authenticity_token"
    input.autocomplete = "off"
    input.value = window.mrujs.csrfToken()

    return input
  }
}
