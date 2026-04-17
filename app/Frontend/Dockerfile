# Frontend - Node.js
FROM node:18-alpine

# Create a non-root user and group for security
RUN addgroup -S fegroup && adduser -S feuser -G fegroup

WORKDIR /app

# Install dependencies first (layer caching)
COPY --chown=feuser:fegroup package*.json ./
RUN npm install --omit=dev

# Copy application source
COPY --chown=feuser:fegroup . .

# Switch to the non-root user
USER feuser

EXPOSE 22137

CMD ["node", "fe-server.js"]
