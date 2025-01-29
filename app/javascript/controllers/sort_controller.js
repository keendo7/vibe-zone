import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"];

  update() {
    const form = this.selectTarget.closest("form");
    if (form) {
      form.requestSubmit();
    }
  }
}