import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  static targets = ["image"]

  toggleElement(event, paramKey) {
    event.preventDefault();
    event.stopPropagation();
    const elementId = event.params[paramKey];
    const element = document.getElementById(elementId);
    element.classList.toggle("d-none");
  }

  showToggleButton(event) {
    event.target.classList.add("hidden");
    const buttonId = event.params["button"];
    const button = document.getElementById(buttonId);
    button.classList.toggle("d-none");
  }

  toggleForm(event) {
    this.toggleElement(event, "form");
  }

  toggleReplies(event) {
    this.toggleElement(event, "replies");
  }

  toggleImageSize(event) {
    event.target.classList.toggle("image-small");
  }
}
