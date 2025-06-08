import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="user-banner"
export default class extends Controller {
  uploadBanner(event) {
    const file = event.target.files[0];
    const size_in_megabytes = file.size/1024/1024;
    
    if (size_in_megabytes > 5) {
      alert("Maximum file size is 5MB. Please choose a smaller file.");
      return;
    }

    const reader = new FileReader();

    reader.onloadend = () => {
      document.getElementById('banner').src = reader.result;
    };

    if (file) {
      reader.readAsDataURL(file);
      this.saveBanner(file);
    }
  }

  async saveBanner(file) {
    const formData = new FormData();
    formData.append('user[banner]', file);

    try {
      await fetch("/update_banner", {
        method: 'PATCH',
        body: formData,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
      });
    } catch (error) {
      console.error('Error saving avatar:', error);
    }
  }
}
