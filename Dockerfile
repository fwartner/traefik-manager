# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Build the application
RUN npm run build

# Production stage
FROM node:20-alpine AS production

# Create app user
RUN addgroup -g 1001 -S traefik-manager && \
    adduser -S traefik-manager -u 1001 -G traefik-manager

WORKDIR /app

# Copy built application
COPY --from=builder --chown=traefik-manager:traefik-manager /app/.output ./
COPY --from=builder --chown=traefik-manager:traefik-manager /app/package*.json ./

# Install only production dependencies if needed
RUN npm ci --only=production --ignore-scripts || true

# Create traefik config directory
RUN mkdir -p /etc/traefik/dynamic && \
    chown -R traefik-manager:traefik-manager /etc/traefik

# Switch to app user
USER traefik-manager

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "const http = require('http'); http.get('http://localhost:3000/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1); }).on('error', () => process.exit(1));"

# Start the application
CMD ["node", "server/index.mjs"]
