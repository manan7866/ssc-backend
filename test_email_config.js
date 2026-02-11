import nodemailer from "nodemailer";
import dotenv from "dotenv";
dotenv.config();

const SMTP_HOST = process.env.SMTP_HOST;
const SMTP_PORT = parseInt(process.env.SMTP_PORT || "465");
const HOST_EMAIL = process.env.SMTP_HOST_EMAIL;
const HOST_EMAIL_SECRET = process.env.SMTP_SECRET;

console.log("Testing email configuration...");
console.log("SMTP Host:", SMTP_HOST);
console.log("SMTP Port:", SMTP_PORT);
console.log("Email Address:", HOST_EMAIL);

const transporter = nodemailer.createTransport({
  host: SMTP_HOST,
  port: SMTP_PORT,
  secure: true, // true for 465, false for other ports
  auth: {
    user: "resend",
    pass: HOST_EMAIL_SECRET
  }
});

// Verify the connection
transporter.verify((error, success) => {
  if (error) {
    console.error("❌ SMTP Connection Failed:", error.message);
    console.error("Error details:", error);
  } else {
    console.log("✅ SMTP Connection Successful!");

    // Try sending a test email
    const mailOptions = {
      from: HOST_EMAIL,
      to: "abdulmananwighio06@gmail.com", // Replace with your own email to test
      subject: "Test Email from SufiScience Center",
      text: "This is a test email to verify the SMTP configuration.",
      html: "<h1>This is a test email</h1><p>If you received this, your SMTP configuration is working!</p>"
    };

    transporter.sendMail(mailOptions, (err, info) => {
      if (err) {
        console.error("❌ Email sending failed:", err.message);
        console.error("Error details:", err);
      } else {
        console.log("✅ Test email sent successfully!");
        console.log("Response:", info.response);
      }
    });
  }
});
