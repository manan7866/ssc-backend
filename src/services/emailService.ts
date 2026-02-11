import { Resend } from "resend";
import { HOST_EMAIL, HOST_EMAIL_SECRET } from "../configs/config.js";
import logger from "../utils/loggerUtils.js";

// Initialize Resend client
const resend = new Resend(HOST_EMAIL_SECRET);

export interface EmailTemplate {
  id: string;
  variables: Record<string, string>;
}

export interface EmailOptions {
  to: string;
  subject?: string;
  template?: EmailTemplate;
}

/**
 * Send email using Resend with template support (using predefined templates on Resend)
 */
export async function sendEmailWithTemplate(options: EmailOptions): Promise<{ success: boolean; messageId?: string; error?: string }> {
  try {
    const { to, subject = "Email from Sufism Ecommerce", template } = options;

    // If template is provided, use Resend's template functionality with variables
    if (template) {
      // Using Resend's API to send emails with templates defined in their dashboard
      const result = await resend.emails.send({
        from: HOST_EMAIL,
        to: Array.isArray(to) ? to : [to],
        subject: subject,
        template: {
          id: template.id,
          variables: template.variables
        }
      });

      if (result.error) {
        logger.error(`Error sending email with template: ${result.error.message}`, { error: result.error });
        return { success: false, error: result.error.message };
      }

      logger.info(`Email sent successfully with template: ${result.data?.id}`);
      return { success: true, messageId: result.data?.id };
    } else {
      logger.error("Template is required for this implementation");
      return { success: false, error: "Template is required for this implementation" };
    }
  } catch (error) {
    logger.error(`Unexpected error sending email: ${error instanceof Error ? error.message : String(error)}`, { error });
    return { success: false, error: error instanceof Error ? error.message : String(error) };
  }
}

/**
 * Send OTP email using template
 */
export async function sendOTPEmail(
  to: string,
  otp: string,
  templateId: string = "email-verification-code"
): Promise<{ success: boolean; messageId?: string; error?: string }> {
  return sendEmailWithTemplate({
    to,
    subject: "Your Verification Code",
    template: {
      id: templateId,
      variables: {
        OTP_CODE: otp
      }
    }
  });
}
