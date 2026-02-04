# Multi-stage optimized Dockerfile for backend
# Stage 1: Dependencies stage (build-time dependencies)
FROM oven/bun:latest AS deps

WORKDIR /app

# Copy package files
COPY package.json bun.lock ./

# Install ALL dependencies (including dev dependencies for building)
# Use offline mode if available
RUN bun install --offline || bun install

# Stage 2: Builder stage
FROM oven/bun:latest AS builder

WORKDIR /app

# Copy dependencies
COPY --from=deps /app/node_modules ./node_modules
COPY package.json bun.lock ./

# Copy source code
COPY . .

# Generate Prisma client and build the application
RUN bun run db:generate
RUN bun run build

# Stage 3: Production dependencies stage (runtime dependencies only)
FROM oven/bun:slim AS production-deps

WORKDIR /app

# Copy package files
COPY package.json bun.lock ./

# Install only production dependencies with prepare scripts disabled
RUN HUSKY=0 npm_config_ignore_scripts=true DISABLE_OPENCOLLECTIVE=1 npm_config_audit=false npm_config_fund=false bun install --production --ignore-scripts --offline || HUSKY=0 npm_config_ignore_scripts=true DISABLE_OPENCOLLECTIVE=1 npm_config_audit=false npm_config_fund=false bun install --production --ignore-scripts

# Stage 4: Final production stage - smallest possible image
FROM oven/bun:slim AS production

WORKDIR /app

# Copy production dependencies
COPY --from=production-deps /app/node_modules ./node_modules

# Copy built application and generated Prisma client (from builder stage where it was already generated)
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/templates ./templates
COPY --from=builder /app/public ./public
COPY --from=builder /app/uploads ./uploads

# Create non-root user for security
RUN groupadd -g 1001 nodejs && \
    useradd -u 1001 -g nodejs nodejs

# Create logs directory and set permissions for the non-root user
RUN mkdir -p logs && \
    chown -R nodejs:nodejs /app && \
    chmod 755 /app && \
    chmod 777 logs

# Switch to non-root user
USER nodejs:nodejs

# Expose port (default is 8001 as seen in config)
EXPOSE 8001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8001/health || exit 1

CMD ["bun", "./dist/server.js"]