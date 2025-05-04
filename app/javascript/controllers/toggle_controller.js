import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

static targets = ["link"];

  toggleForm(event) {
    event.preventDefault();
    event.stopPropagation();
    const formId = event.params["form"];
    const form = document.getElementById(formId);
    form.classList.toggle("d-none");
  }

  showButton(event) {
    const buttonId = event.params["button"];
    const button = document.getElementById(buttonId);
    button.classList.toggle("d-none");
  }

  toggleReplies(event) {
    event.preventDefault();
    event.stopPropagation();
    const repliesId = event.params["replies"];
    console.log(event);
    const replies = document.getElementById(repliesId);
    replies.classList.toggle("d-none");

    if(this.linkTarget.textContent == "Hide replies"){
      this.linkTarget.textContent = "Show replies";
    } else {
      this.linkTarget.textContent = "Hide replies";
    }
  }
}
