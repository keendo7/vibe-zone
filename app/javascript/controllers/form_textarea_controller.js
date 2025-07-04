import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-textarea"
export default class extends Controller {

  static targets = ["input"];

  connect() {
    this.inputTarget.style.resize = 'none';
    this.inputTarget.style.minHeight = `${this.inputTarget.scrollHeight}px`;
    this.inputTarget.style.overflow = 'hidden';
  }

  resize(event){
    event.target.style.height = '5px';
    event.target.style.height = `${event.target.scrollHeight}px`;
  }
}
