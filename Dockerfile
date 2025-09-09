# Multi-stage Dockerfile for Material Dashboard 2 React Application
# Stage 1: Build stage
FROM node:18.20.4-alpine AS builder

# Install security updates
RUN apk update && apk upgrade && apk add --no-cache dumb-init

# Create app directory with proper permissions
WORKDIR /usr/src/app

# Create non-root user for build stage
RUN addgroup -g 1001 -S nodejs && \
    adduser -S reactuser -u 1001 -G nodejs

# Copy package files
COPY package*.json ./

# Install dependencies with security fixes
# Remove existing lock file to avoid version conflicts and install all dependencies
RUN rm -f package-lock.json && \
    npm install && \
    npm audit fix --force && \
    npm cache clean --force

# Copy source code
COPY . .

# Change ownership to non-root user
RUN chown -R reactuser:nodejs /usr/src/app
USER reactuser

# Build the application
RUN npm run build

# Stage 2: Production stage
FROM nginx:1.25.3-alpine AS production

# Install security updates and required packages
RUN apk update && apk upgrade && \
    apk add --no-cache dumb-init && \
    rm -rf /var/cache/apk/*

# Create non-root user (use existing nginx group)
RUN adduser -S appuser -u 1001 -G nginx

# Remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/

# Copy built application from builder stage
COPY --from=builder --chown=appuser:nginx /usr/src/app/build /usr/share/nginx/html

# Set proper permissions
RUN chmod -R 755 /usr/share/nginx/html && \
    chown -R appuser:nginx /usr/share/nginx/html && \
    chown -R appuser:nginx /var/cache/nginx && \
    chown -R appuser:nginx /var/log/nginx && \
    chown -R appuser:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R appuser:nginx /var/run/nginx.pid

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
