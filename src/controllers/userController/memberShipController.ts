import reshttp from "reshttp";
import { db } from "../../configs/database.js";
import type { _Request } from "../../middleware/authMiddleware.js";
import type { TMEMBERSHIP } from "../../type/types.js";
import { httpResponse } from "../../utils/apiResponseUtils.js";
import { asyncHandler } from "../../utils/asyncHandlerUtils.js";
import logger from "../../utils/loggerUtils.js";
import { gloabalMailMessage } from "../../services/globalEmailMessageService.js";

export default {
  membership: asyncHandler(async (req: _Request, res) => {
    const data = req.body as TMEMBERSHIP;
    logger.info(data.collaboratorIntent);
    logger.info("*****************************");
    const user = await db.user.findFirst({
      where: {
        id: req.userFromToken?.id
      }
    });

    if (!user) {
      return httpResponse(req, res, reshttp.unauthorizedCode, reshttp.unauthorizedMessage);
    }
    const existingMember = await db.member.findFirst({
      where: {
        userId: user.id
      }
    });
    if (existingMember) {
      return httpResponse(req, res, reshttp.conflictCode, "Membership already exists", existingMember);
    }
    // Create Member
    const member = await db.member.create({
      data: {
        user: {
          connect: { id: user.id }
        },
        phone: data.phone,
        country: data.country,
        agreedToPrinciples: data.agreedToPrinciples,
        consentedToUpdates: data.consentedToUpdates,
        additionalInfo: data.additionalInfo,
        collaboratorIntent: data.collaboratorIntent,
        donorType: data.donorType,
        intentCreation: data.intentCreation,
        monthlyTime: data.monthlyTime,
        organization: data.organization,
        previousVolunteerExp: data.previousVolunteerExp,
        role: data.role,
        volunteerMode: data.volunteerMode,
        volunteerSupport: data.volunteerSupport
      }
    });

    // Send confirmation email based on membership type
    try {
      // Determine the membership type and send appropriate email
      const roles = Array.isArray(data.role) ? data.role : [data.role];

      for (const role of roles) {
        switch (role) {
          case "collaborator":
            await gloabalMailMessage(
              user.email,
              `Dear ${user.fullName}, thank you for applying as a collaborator.`,
              "Collaboration Inquiry Confirmation",
              undefined,
              undefined,
              `Hi ${user.fullName}`,
              {
                id: "collaboration-inquiry-confirmation",
                variables: {
                  FULL_NAME: user.fullName || "User",
                  COLLABORATION_INTENT: Array.isArray(data.collaboratorIntent)
                    ? data.collaboratorIntent.join(", ")
                    : data.collaboratorIntent || "Not specified",
                  ORGANIZATION_NAME: data.organization || "Not specified"
                }
              }
            );
            break;

          case "volunteer":
            await gloabalMailMessage(
              user.email,
              `Dear ${user.fullName}, thank you for applying as a volunteer.`,
              "Volunteer Application Confirmation",
              undefined,
              undefined,
              `Hi ${user.fullName}`,
              {
                id: "volunteer-application-confirmation",
                variables: {
                  FULL_NAME: user.fullName || "User",
                  AREAS_OF_SUPPORT: data.volunteerSupport?.join(", ") || "Not specified",
                  PREFERRED_MODE: data.volunteerMode || "Not specified"
                }
              }
            );
            break;

          case "donor":
            await gloabalMailMessage(
              user.email,
              `Dear ${user.fullName}, thank you for applying as a donor.`,
              "Donor Application Confirmation",
              undefined,
              undefined,
              `Hi ${user.fullName}`,
              {
                id: "donor-application-confirmation",
                variables: {
                  FULL_NAME: user.fullName || "User",
                  DONOR_PREFERENCES: data.donorType?.join(", ") || "Not specified"
                }
              }
            );
            break;
        }
      }
    } catch (emailError) {
      logger.error("Error sending membership confirmation email:", emailError);
      // Don't fail the whole operation if email sending fails
    }

    logger.info("Membership created");
    return httpResponse(req, res, reshttp.createdCode, "Membership created", member);
  }),
  viewMembership: asyncHandler(async (req: _Request, res) => {
    const userId = req.userFromToken?.id;
    const user = await db.user.findFirst({
      where: { id: userId }
    });
    if (!user) {
      logger.info("Unauthorize user");
      return httpResponse(req, res, reshttp.unauthorizedCode, reshttp.unauthorizedMessage);
    }
    const member = await db.member.findFirst({
      where: {
        userId: user.id
      }
    });
    if (!member) {
      logger.info("Membership not found");
      return httpResponse(req, res, reshttp.notFoundCode, "Membership not found");
    }
    logger.info("Membership fetched");
    logger.info(member);
    return httpResponse(req, res, reshttp.acceptedCode, "Membership fetched", member);
  }),
  updateMembership: asyncHandler(async (req: _Request, res) => {
    const data = req.body as Partial<TMEMBERSHIP>;

    const user = await db.user.findFirst({
      where: {
        id: req.userFromToken?.id
      }
    });

    if (!user) {
      return httpResponse(req, res, reshttp.unauthorizedCode, reshttp.unauthorizedMessage);
    }

    const existingMember = await db.member.findFirst({
      where: {
        userId: user.id
      }
    });

    if (!existingMember) {
      return httpResponse(req, res, reshttp.notFoundCode, "Membership not found");
    }

    const updatedMember = await db.member.update({
      where: {
        id: existingMember.id
      },
      data: {
        phone: data.phone ?? existingMember.phone,
        country: data.country ?? existingMember.country,
        agreedToPrinciples: data.agreedToPrinciples ?? existingMember.agreedToPrinciples,
        consentedToUpdates: data.consentedToUpdates ?? existingMember.consentedToUpdates,
        additionalInfo: data.additionalInfo ?? existingMember.additionalInfo,
        collaboratorIntent: data.collaboratorIntent ?? existingMember.collaboratorIntent,
        donorType: data.donorType ?? existingMember.donorType,
        intentCreation: data.intentCreation ?? existingMember.intentCreation,
        monthlyTime: data.monthlyTime ?? existingMember.monthlyTime,
        organization: data.organization ?? existingMember.organization,
        previousVolunteerExp: data.previousVolunteerExp ?? existingMember.previousVolunteerExp,
        role: data.role ?? existingMember.role,
        volunteerMode: data.volunteerMode ?? existingMember.volunteerMode,
        volunteerSupport: data.volunteerSupport ?? existingMember.volunteerSupport
      }
    });

    return httpResponse(req, res, reshttp.okCode, "Membership updated", updatedMember);
  }),
  deleteMembership: asyncHandler(async (req: _Request, res) => {
    const user = await db.user.findFirst({
      where: {
        id: req.userFromToken?.id
      }
    });

    if (!user) {
      return httpResponse(req, res, reshttp.unauthorizedCode, reshttp.unauthorizedMessage);
    }

    const existingMember = await db.member.findFirst({
      where: {
        userId: user.id
      }
    });

    if (!existingMember) {
      return httpResponse(req, res, reshttp.notFoundCode, "Membership not found");
    }

    // Delete the member
    await db.member.delete({
      where: {
        id: existingMember.id
      }
    });

    return httpResponse(req, res, reshttp.okCode, "Membership deleted successfully");
  })
};
