import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.fadeOutAndRemove()
    }, 4000)
  }

  fadeOutAndRemove() {
    this.element.style.transition = "opacity 0.2s ease-out"
    this.element.style.opacity = "0"

    setTimeout(() => {
      this.element.remove()
    }, 200)
  }
}
