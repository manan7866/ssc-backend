import "dotenv/config";
import { connectDB } from "./configs/database.js";
import { app } from "./app.js";
import logger from "./utils/loggerUtils.js";
import { PORT } from "./configs/config.js";

const startServer = async () => {
  try {
    await connectDB();

    app.listen(PORT, () => {
      logger.info(`Server is running on port ${PORT}`);
    });

    // Graceful shutdown
    process.on("SIGTERM", () => {
      logger.info("SIGTERM received, shutting down gracefully");
      process.exit(0);
    });

    process.on("SIGINT", () => {
      logger.info("SIGINT received, shutting down gracefully");
      process.exit(0);
    });
  } catch (error) {
    logger.error("Failed to start server:", error);
    process.exit(1);
  }
};

void startServer();
