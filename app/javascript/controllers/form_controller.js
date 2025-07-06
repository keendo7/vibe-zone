import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {

  static targets = ["input", "counter", "submit"];

  connect() {
    this.inputTarget.style.resize = 'none';
    this.inputTarget.style.minHeight = `${this.inputTarget.scrollHeight}px`;
    this.inputTarget.style.overflow = 'hidden';
  }

  resize(event){
    event.target.style.height = '5px';
    event.target.style.height = `${event.target.scrollHeight}px`;
  }

  count(){
    let length = this.inputTarget.value.length;
    
    if (length >= 3 && length <= 200) {
      this.counterTarget.innerText = `${length}/200`;
      this.counterTarget.classList.remove("text-danger", "fw-bold");
      this.submitTarget.classList.remove("disabled");
    } else if (length > 200) {
      this.submitTarget.classList.add("disabled");
      this.counterTarget.classList.add("text-danger", "fw-bold");
      this.counterTarget.innerText = `${length}/200`;
    } else {
      this.submitTarget.classList.add("disabled");
      this.counterTarget.innerText = "";
    }
  }
}
