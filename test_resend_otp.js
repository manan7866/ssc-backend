// Test script to verify the Resend OTP implementation
import { sendOTPEmail } from "./src/services/emailService.js";

async function testOTPSending() {
  console.log("Testing OTP sending with Resend...");

  try {
    // Replace with a test email address
    const testEmail = process.env.TEST_EMAIL || "test@example.com";
    const testOTP = "123456";

    console.log(`Sending OTP to: ${testEmail}`);

    const result = await sendOTPEmail(testEmail, testOTP, "email-verification-code");

    if (result.success) {
      console.log("✅ OTP sent successfully!");
      console.log("Message ID:", result.messageId);
    } else {
      console.error("❌ Failed to send OTP:", result.error);
    }
  } catch (error) {
    console.error("❌ Error sending OTP:", error.message);
  }
}

// Run the test
testOTPSending();
