import reshttp from "reshttp";
import { db } from "../../configs/database.js";
import type { _Request } from "../../middleware/authMiddleware.js";
import { gloabalMailMessage } from "../../services/globalEmailMessageService.js";
import type { TCONTACT_US } from "../../type/types.js";
import { httpResponse } from "../../utils/apiResponseUtils.js";
import { asyncHandler } from "../../utils/asyncHandlerUtils.js";
import logger from "../../utils/loggerUtils.js";

export default {
  contactUs: asyncHandler(async (req: _Request, res) => {
    const data = req.body as TCONTACT_US;
    const user = await db.user.findFirst({
      where: {
        id: req.userFromToken?.id
      }
    });
    if (!user) {
      return httpResponse(req, res, reshttp.unauthorizedCode, reshttp.unauthorizedMessage);
    }
    const newContact = await db.contactUs.create({
      data: {
        userId: user.id,
        message: data.message,
        subject: data.subject
      }
    });

    if (!newContact) {
      return httpResponse(req, res, reshttp.internalServerErrorCode, "Failed to submit contact request");
    }

    // Send confirmation email to the user
    try {
      await gloabalMailMessage(
        user.email,
        `Dear ${user.fullName}, we have received your contact request.`,
        "Contact Confirmation",
        undefined,
        undefined,
        `Hi ${user.fullName}`,
        {
          id: "contact-confirmation",
          variables: {
            FULL_NAME: user.fullName || "User",
            MESSAGE_SUBJECT: data.subject || "General Inquiry"
          }
        }
      );
    } catch (emailError) {
      logger.error("Error sending contact confirmation email:", emailError);
      // Don't fail the whole operation if email sending fails
    }

    return httpResponse(req, res, reshttp.createdCode, reshttp.createdMessage, newContact);
  })
};
