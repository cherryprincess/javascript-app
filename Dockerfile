# Multi-stage secure Dockerfile for React Material Dashboard
# Build stage with enhanced security and reliability
FROM node:18.20.4-alpine3.19 AS builder

# Install security updates and essential tools
RUN apk upgrade --no-cache && \
    apk add --no-cache dumb-init curl && \
    rm -rf /var/cache/apk/*

# Create secure working directory
WORKDIR /app

# Copy package files for optimized Docker layer caching
COPY package*.json ./

# Enhanced dependency installation with dev dependencies for build
RUN echo "🔧 Installing ALL dependencies (including dev) for build stage..." && \
    npm ci --no-audit || \
    (echo "⚠️  npm ci failed, trying npm install with legacy peer deps..." && \
     rm -f package-lock.json && \
     npm cache clean --force && \
     npm install --legacy-peer-deps --no-audit) || \
    (echo "⚠️  Fallback: clean install without lock file..." && \
     npm install --no-package-lock --legacy-peer-deps --no-audit)

# Verify critical build tools are available
RUN echo "🔍 Verifying build tools..." && \
    (npx react-scripts --version && echo "✅ react-scripts verified") || \
    (echo "🔧 Installing react-scripts explicitly..." && npm install react-scripts@5.0.0)

# Copy source code (after dependencies for better caching)
COPY . .

# Build the React application with robust error handling
RUN echo "🚀 Building React application..." && \
    GENERATE_SOURCEMAP=false ESLINT_NO_DEV_ERRORS=true npm run build && \
    echo "✅ Build completed successfully" && \
    ls -la build/ && \
    echo "📊 Build size: $(du -sh build/)" && \
    echo "📁 Build files: $(find build -type f | wc -l)"

# Production stage with hardened nginx
FROM nginx:1.25.3-alpine

# Install security updates and health check tools
RUN apk upgrade --no-cache && \
    apk add --no-cache dumb-init curl && \
    rm -rf /var/cache/apk/*

# Create consistent non-root user with specific UID/GID
RUN addgroup -g 101 -S appgroup && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G appgroup appuser

# Copy built application from build stage
COPY --from=builder --chown=101:101 /app/build /usr/share/nginx/html

# Copy optimized nginx configuration
COPY --chown=101:101 nginx.conf /etc/nginx/conf.d/default.conf

# Set up secure directory permissions
RUN mkdir -p /var/run/nginx /var/cache/nginx /var/log/nginx && \
    chown -R 101:101 /usr/share/nginx/html \
                     /var/cache/nginx \
                     /var/run/nginx \
                     /var/log/nginx \
                     /etc/nginx/conf.d && \
    chmod -R 755 /usr/share/nginx/html && \
    chmod 644 /etc/nginx/conf.d/default.conf && \
    touch /var/run/nginx.pid && \
    chown 101:101 /var/run/nginx.pid

# Switch to non-root user
USER 101:101

# Expose application port
EXPOSE 8080

# Enhanced health check for /health endpoint with proper timing
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:8080/health || exit 1

# Use dumb-init for proper signal handling in containers
ENTRYPOINT ["dumb-init", "--"]

# Start nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]
