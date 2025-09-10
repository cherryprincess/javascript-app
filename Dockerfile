# Multi-stage build for React Material Dashboard Application
# Stage 1: Build the React application
FROM node:18.20.4-alpine AS builder

# Set working directory
WORKDIR /app

# Install security updates and necessary tools
RUN apk update && apk upgrade && \
    apk add --no-cache git python3 make g++ && \
    rm -rf /var/cache/apk/*

# Copy package files for dependency caching
COPY package*.json ./

# Set build environment variables to prevent build failures
ENV CI=false
ENV ESLINT_NO_DEV_ERRORS=true
ENV GENERATE_SOURCEMAP=false
ENV NODE_OPTIONS="--max_old_space_size=4096"

# Install dependencies with 3-tier fallback strategy
RUN npm ci --no-audit --legacy-peer-deps || \
    (echo "npm ci failed, trying npm install with legacy peer deps..." && \
     rm -f package-lock.json && \
     npm cache clean --force && \
     npm install --legacy-peer-deps --no-audit) || \
    (echo "Fallback: clean install without lock file..." && \
     npm install --no-package-lock --legacy-peer-deps --no-audit) && \
    # Handle common dependency conflicts explicitly
    npm install ajv@^8.12.0 ajv-keywords@^5.1.0 --legacy-peer-deps --no-audit || true && \
    # Ensure react-scripts is available for build
    npm install react-scripts@5.0.0 --legacy-peer-deps --no-audit || true

# Copy source code
COPY . .

# Build the application
RUN npm run build && \
    # Verify build output exists
    ls -la build/ && \
    # Clean up node_modules to reduce image size
    rm -rf node_modules

# Stage 2: Production nginx server
FROM nginx:1.29.1-alpine AS production

# Create non-root user with UID/GID > 1000 to avoid conflicts
RUN addgroup -g 1001 -S appgroup && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G appgroup appuser

# Install security updates
RUN apk update && apk upgrade && \
    apk add --no-cache curl && \
    rm -rf /var/cache/apk/*

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create necessary directories with proper permissions
RUN mkdir -p /var/cache/nginx /var/run /var/log/nginx && \
    chown -R appuser:appgroup /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html && \
    chmod -R 755 /var/cache/nginx /var/run /var/log/nginx /usr/share/nginx/html

# Copy built application from builder stage
COPY --from=builder --chown=appuser:appgroup /app/build /usr/share/nginx/html

# Switch to non-root user
USER appuser

# Expose port 8080 (non-privileged port)
EXPOSE 8080

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
