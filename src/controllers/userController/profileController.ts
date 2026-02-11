import reshttp from "reshttp";
import { db } from "../../configs/database.js";
import type { _Request } from "../../middleware/authMiddleware.js";
import type { TPROFILE } from "../../type/types.js";
import { httpResponse } from "../../utils/apiResponseUtils.js";
import { asyncHandler } from "../../utils/asyncHandlerUtils.js";
import logger from "../../utils/loggerUtils.js";

export default {
  viewUserProfile: asyncHandler(async (req: _Request, res) => {
    try {
      // Find user by ID from token with all related forms data (excluding contactUs)
      const user = await db.user.findFirst({
        where: { id: req.userFromToken?.id },
        select: {
          id: true,
          fullName: true,
          lastName: true,
          email: true,
          address: true,
          city: true,
          state: true,
          zipCode: true,
          country: true,
          phone: true,
          avatar: true,
          createdAt: true, // Account creation date

          // Include all user-filled forms (excluding contactUs as requested)
          member: {
            select: {
              phone: true,
              country: true,
              role: true,
              volunteerSupport: true,
              previousVolunteerExp: true,
              monthlyTime: true,
              volunteerMode: true,
              donorType: true,
              collaboratorIntent: true,
              organization: true,
              intentCreation: true,
              additionalInfo: true,
              agreedToPrinciples: true,
              consentedToUpdates: true,
              createdAt: true
            }
          },
          donation: {
            select: {
              amount: true,
              pool: true,
              donorType: true,
              createdAt: true
            }
          },
          reviews: {
            select: {
              id: true,
              rating: true,
              content: true,
              createdAt: true
            }
          },
          bookService: {
            select: {
              id: true,
              subject: true,
              date: true,
              service: true,
              comment: true,
              status: true,
              createdAt: true
            }
          },
          interview: {
            select: {
              id: true,
              profession: true,
              institution: true,
              website: true,
              areasOfImpact: true,
              spiritualOrientation: true,
              publicVoice: true,
              interviewIntent: true,
              status: true,
              scheduledAt: true,
              additionalNotes: true,
              createdAt: true
            }
          },
          conference: {
            select: {
              id: true,
              institution: true,
              abstract: true,
              presentationType: true,
              topic: true,
              status: true,
              createdAt: true
            }
          },
          sufiChecklist: {
            select: {
              id: true,
              progress: true,
              createdAt: true,
              items: {
                select: {
                  id: true,
                  section: true,
                  title: true,
                  status: true,
                  createdAt: true
                }
              }
            }
          }
        }
      });

      if (!user) {
        return httpResponse(req, res, reshttp.unauthorizedCode, reshttp.unauthorizedMessage);
      }

      // Return user profile data with forms
      return httpResponse(req, res, reshttp.okCode, "Profile retrieved successfully", {
        profile: {
          ...user,
          // Format the forms data to be more readable
          accountCreatedDate: user.createdAt,
          forms: {
            membership: user.member ? user.member : null,
            donations: user.donation ? [user.donation] : [],
            reviews: user.reviews,
            bookedServices: user.bookService,
            interviews: user.interview ? [user.interview] : [],
            conferences: user.conference ? [user.conference] : [],
            sufiChecklist: user.sufiChecklist ? user.sufiChecklist : null
          }
        }
      });
    } catch (error) {
      logger.error("Error fetching user profile:", error);
      return httpResponse(req, res, reshttp.internalServerErrorCode, "Error retrieving profile");
    }
  }),

  updateUserProfile: asyncHandler(async (req: _Request, res) => {
    const data = req.body as Partial<TPROFILE>;
    const user = await db.user.findFirst({
      where: { id: req.userFromToken?.id }
    });

    if (!user) return httpResponse(req, res, reshttp.unauthorizedCode, reshttp.unauthorizedMessage);

    try {
      const updateResult = await db.user.update({
        where: { id: user.id },
        data: {
          fullName: data.fullName,
          lastName: data.lastName,
          address: data.address,
          city: data.city,
          country: data.country,
          state: data.state,
          zipCode: data.zipCode,
          phone: data.phone,
          avatar: data.avatar // Add avatar update
          // Add signature date update
        }
      });

      if (updateResult) {
        return httpResponse(req, res, reshttp.okCode, reshttp.okMessage);
      } else {
        return httpResponse(req, res, reshttp.badRequestCode, "Failed to update profile");
      }
    } catch (error) {
      logger.error("Error updating profile:", error);
      return httpResponse(req, res, reshttp.internalServerErrorCode, "Error updating profile");
    }
  }),

  uploadAvatar: asyncHandler(async (req: _Request, res) => {
    try {
      // Check if file was uploaded
      if (!req.file) {
        return httpResponse(req, res, reshttp.badRequestCode, "No image file uploaded");
      }

      // The file path is stored in req.file.path for Cloudinary uploads
      const file = req.file as { path?: string; secure_url?: string; filename: string };
      const imageUrl = file.path || file.secure_url || file.filename;

      // Update user's avatar in database
      const updatedUser = await db.user.update({
        where: { id: req.userFromToken?.id },
        data: { avatar: imageUrl }
      });

      if (updatedUser) {
        return httpResponse(req, res, reshttp.okCode, "Avatar uploaded successfully", { avatar: imageUrl });
      } else {
        return httpResponse(req, res, reshttp.badRequestCode, "Failed to update avatar");
      }
    } catch (error) {
      logger.error("Error uploading avatar:", error);
      return httpResponse(req, res, reshttp.internalServerErrorCode, "Error uploading avatar");
    }
  })
};
