FROM node:18

# Set the working directory
WORKDIR /usr/src/app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy application source code
COPY . .

# Expose the port
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
