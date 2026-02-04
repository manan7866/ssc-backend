import { PrismaClient } from "@prisma/client";
import logger from "../utils/loggerUtils.js";

process.env.NODE_ENV = process.env.NODE_ENV || "production";
const db = new PrismaClient({});

const connectDB = async (): Promise<void> => {
  try {
    await db.$connect();
    logger.info("Connected to the database successfully ✅");
  } catch (err: unknown) {
    if (err instanceof Error) logger.error(`Database connection error: ${err.message}`);
    else logger.error("Error connecting to DB", { err });
    process.exit(1);
  }
};

export { connectDB, db };
