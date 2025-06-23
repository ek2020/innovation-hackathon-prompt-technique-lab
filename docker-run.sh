#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker to run this demo."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Please install Docker Compose to run this demo."
    exit 1
fi

# Check if backend/.env file exists
if [ ! -f "./backend/.env" ]; then
    echo "No .env file found in backend directory."
    
    if [ -f "./backend/.env.azure" ]; then
        echo "Creating .env file from .env.azure..."
        cp ./backend/.env.azure ./backend/.env
        echo ".env file created. Please edit it to add your Azure OpenAI API key."
    elif [ -f "./backend/.env.example" ]; then
        echo "Creating .env file from .env.example..."
        cp ./backend/.env.example ./backend/.env
        echo ".env file created. Please edit it to add your OpenAI API key."
    else
        echo "No template files found. Please create a backend/.env file with your API configuration."
        exit 1
    fi
    
    echo "Please edit ./backend/.env to add your API key before continuing."
    exit 1
fi

# Build and start the Docker containers
echo "Building and starting Docker containers..."
docker-compose up --build

# The script will continue running until the user presses Ctrl+C
