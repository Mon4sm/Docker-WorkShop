# syntax=docker/dockerfile:1.7

# =============================================================================
# Builder stage — installs production dependencies only, on a fresh Node base.
# =============================================================================

# TODO(step-4a): set the builder base image as node:20.11-slim and name the stage "builder".
FROM node:20.11-slim AS builder

WORKDIR /app

# TODO(step-4b): Update path to point to the app folder
COPY app/package*.json ./
RUN npm install --omit=dev

# TODO(step-4c): Update path to copy the app source
COPY app/ .

# =============================================================================
# Runtime stage — slim final image. Nothing from builder's caches leaks in.
# =============================================================================

# TODO(step-4d): set the runtime base image (same tag as step-4a for consistency).
FROM node:20.11-slim

WORKDIR /app

# TODO(step-4e): copy the fully-installed app from the builder stage.
COPY --from=builder /app /app

ENV NODE_ENV=production
EXPOSE 3000

# TODO(step-4f): add a HEALTHCHECK that probes http://localhost:3000/health.
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=5 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => { if (r.statusCode === 200) process.exit(0); else process.exit(1); }).on('error', () => process.exit(1))"

# TODO(step-4g): declare the container start command.
CMD ["node", "src/index.js"]
