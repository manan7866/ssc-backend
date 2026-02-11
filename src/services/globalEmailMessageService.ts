import reshttp from "reshttp";
import constant from "../constants/constant.js";
import logger from "../utils/loggerUtils.js";
import { sendEmailWithTemplate } from "./emailService.js";
import type { EmailTemplate } from "./emailService.js";

export async function gloabalMailMessage(
  to: string,
  message?: string | null,
  subject?: string,
  _header?: string,
  _addsOn?: string,
  _senderIntro?: string,
  template?: EmailTemplate
) {
  // If a template is provided, use the new Resend service
  if (template) {
    try {
      const result = await sendEmailWithTemplate({
        to,
        subject: subject ?? constant.COMPANY_NAME,
        template: template
      });

      if (!result.success) {
        logger.error(`Error sending email with template: ${result.error}`);
        throw {
          status: reshttp.internalServerErrorCode,
          message: result.error || reshttp.internalServerErrorMessage
        };
      }

      logger.info(`Email message sent successfully with template: ${result.messageId}`);
      return result;
    } catch (error) {
      if (error instanceof Error) {
        logger.error(`Error Email message sending with template: ${error.message}`);
        throw { status: reshttp.internalServerErrorCode, message: reshttp.internalServerErrorMessage };
      }
      logger.error(`Error sending Email message with template: ${error as string}`, { error });
      throw { status: reshttp.internalServerErrorCode, message: reshttp.notImplementedMessage };
    }
  }

  // Fallback to original implementation for backward compatibility
  try {
    // Use the new email service with a basic template
    const result = await sendEmailWithTemplate({
      to,
      subject: subject ?? constant.COMPANY_NAME,
      template: {
        id: "basic-html-template", // This would be a default template in Resend
        variables: {
          content: message || "",
          companyName: constant.COMPANY_NAME || "Sufism Ecommerce"
        }
      }
    });

    if (!result.success) {
      logger.error(`Error sending email: ${result.error}`);
      throw {
        status: reshttp.internalServerErrorCode,
        message: result.error || reshttp.internalServerErrorMessage
      };
    }

    logger.info(`Email message sent successfully: ${result.messageId}`);
    return result;
  } catch (error) {
    if (error instanceof Error) {
      logger.error(`Error Email message sending: ${error.message}`);
      throw { status: reshttp.internalServerErrorCode, message: reshttp.internalServerErrorMessage };
    }
    logger.error(`Error sending Email message: ${error as string}`, { error });
    throw { status: reshttp.internalServerErrorCode, message: reshttp.notImplementedMessage };
  }
}
