import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  toggleForm(event) {
    console.log("cock");
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

  hideReplies(event) {
    event.preventDefault();
    event.stopPropagation();
    const repliesId = event.params["replies"];
    const replies = document.getElementById(repliesId);
    replies.classList.toggle("d-none");
  }
}
