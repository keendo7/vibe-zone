import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
  }

  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
