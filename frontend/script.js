// TODO: replace with your actual API Gateway invoke URL + /submit
// This is the "gateway_url" output from Terraform, e.g.:
// https://abc123xyz.execute-api.ca-central-1.amazonaws.com/prod/submit
const API_URL = "https://REPLACE_ME.execute-api.ca-central-1.amazonaws.com/prod/submit";

const form = document.getElementById("contactForm");
const submitBtn = document.getElementById("submitBtn");
const formMessage = document.getElementById("formMessage");

form.addEventListener("submit", async (event) => {
  event.preventDefault(); // stop the browser's default full-page-reload submit

  // Basic client-side check: make sure required fields aren't blank
  // (the browser's "required" attribute already helps with this,
  // but we double check here before sending)
  const fullName = document.getElementById("fullName").value.trim();
  const email = document.getElementById("email").value.trim();
  const phone = document.getElementById("phone").value.trim();
  const howFoundUs = document.getElementById("howFoundUs").value;
  const customerType = document.getElementById("customerType").value;
  const message = document.getElementById("message").value.trim();
  const website = document.getElementById("website").value; // honeypot

  if (!fullName || !email || !phone || !howFoundUs || !customerType) {
    showMessage("Please fill in all required fields.", "error");
    return;
  }

  const payload = {
    fullName,
    email,
    phone,
    howFoundUs,
    customerType,
    message,
    website // honeypot value, empty for real humans
  };

  setLoading(true);

  try {
    const response = await fetch(API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify(payload)
    });

    const data = await response.json();

    if (!response.ok) {
      // Lambda returned a 400 (validation failed) or another error status
      const errorText = data.errors ? data.errors.join(", ") : (data.message || "Something went wrong.");
      showMessage(errorText, "error");
      return;
    }

    showMessage(data.message || "Thank you! Your inquiry has been received.", "success");
    form.reset();

  } catch (err) {
    console.error("Submission failed:", err);
    showMessage("Network error. Please try again in a moment.", "error");
  } finally {
    setLoading(false);
  }
});

function setLoading(isLoading) {
  submitBtn.disabled = isLoading;
  submitBtn.textContent = isLoading ? "Sending..." : "Send Inquiry";
}

function showMessage(text, type) {
  formMessage.textContent = text;
  formMessage.className = "form-message " + type;
}