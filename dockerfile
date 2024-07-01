# Use Node 20 as the base image
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Install Meteor 3.0
RUN curl https://install.meteor.com/?release=3.0-rc.4 | sh

# Create a non-root user
RUN useradd -m meteoruser

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Set ownership of the app directory to the non-root user
RUN chown -R meteoruser:meteoruser /app

# Switch to the non-root user
USER meteoruser

# Install dependencies
RUN meteor npm install

# Copy the rest of your app's source code
COPY --chown=meteoruser:meteoruser . .

# Build the Meteor app
RUN meteor build --directory /app/build --server-only

# Change to the built app directory
WORKDIR /app/build/bundle

# Install production dependencies
RUN cd programs/server && npm install

# Expose the port your app runs on
EXPOSE 3000

# Set the environment variable for the MongoDB URL
# You should replace this with your actual MongoDB URL when running the container
ENV MONGO_URL=mongodb://localhost:27017/meteorapp

# Set the environment variable for the root URL
# Replace this with your app's URL when deploying
ENV ROOT_URL=http://localhost

# Set the port number
ENV PORT=3000

# Start the application
CMD ["node", "main.js"]