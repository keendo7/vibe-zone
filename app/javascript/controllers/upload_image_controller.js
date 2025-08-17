import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="upload-image"
export default class extends Controller {
  upload(event) {
    const file = event.target.files[0];
    const size_in_megabytes = file.size/1024/1024;
    
    if (size_in_megabytes > 5) {
      alert("Maximum file size is 5MB. Please choose a smaller file.");
      return;
    }

    event.target.form.requestSubmit();
  }
}
