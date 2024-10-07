# Use an official Python runtime as a parent image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app
RUN rm -rf /app/tf-cdk/*

# Install dependencies for Rye
RUN apt-get update && apt-get install -y curl bash

# Install rye
RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash
ENV PATH="/root/.rye/shims:$PATH"

# Sync dependencies
RUN rye sync

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=server.py
ENV PORT=5000

# Run app.py when the container launches
CMD ["rye", "run", "python", "server/server.py"]
