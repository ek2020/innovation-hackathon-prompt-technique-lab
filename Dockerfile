FROM node:18

# Create app directory
WORKDIR /app

# Copy package.json files
COPY backend/package.json backend/
COPY backend/package-lock.json* backend/

# Install backend dependencies
RUN cd backend && npm install

# Copy project files
COPY . .

# Install http-server globally
RUN npm install -g http-server

# Expose ports for backend API and frontend HTTP server
EXPOSE 3000 8080

# Create a startup script
RUN echo '#!/bin/bash\n\
cd /app/backend && node server.js & \n\
cd /app && http-server -p 8080 \n\
wait' > /app/docker-start.sh

# Make the script executable
RUN chmod +x /app/docker-start.sh

# Start both servers
CMD ["/app/docker-start.sh"]
