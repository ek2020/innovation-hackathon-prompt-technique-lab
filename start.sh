#!/bin/bash

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js to run this demo."
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install npm to run this demo."
    exit 1
fi

# Check for command line arguments
USE_AZURE=false
if [ "$1" == "--azure" ]; then
    USE_AZURE=true
    echo "Using Azure OpenAI configuration..."
fi

# Check if .env file exists in backend directory
if [ ! -f "./backend/.env" ]; then
    echo "No .env file found in backend directory."
    
    if [ "$USE_AZURE" = true ] && [ -f "./backend/.env.azure" ]; then
        echo "Creating .env file from .env.azure..."
        cp ./backend/.env.azure ./backend/.env
        echo ".env file created. Please edit it to add your Azure OpenAI API key."
    elif [ -f "./backend/.env.example" ]; then
        echo "Creating .env file from .env.example..."
        cp ./backend/.env.example ./backend/.env
        echo ".env file created. Please edit it to add your OpenAI API key."
    else
        echo "No template files found. Creating a new .env file..."
        echo "# OpenAI API Configuration" > ./backend/.env
        echo "OPENAI_API_KEY=your_openai_api_key_here" >> ./backend/.env
        echo "OPENAI_MODEL_ID=gpt-4o" >> ./backend/.env
        echo "" >> ./backend/.env
        echo "# For Azure OpenAI (uncomment and fill these if using Azure)" >> ./backend/.env
        echo "# OPENAI_API_TYPE=azure" >> ./backend/.env
        echo "# OPENAI_API_BASE=https://hai-build-enablement.openai.azure.com/" >> ./backend/.env
        echo "# OPENAI_API_VERSION=2023-05-15" >> ./backend/.env
        echo "" >> ./backend/.env
        echo "# Server Port" >> ./backend/.env
        echo "PORT=3000" >> ./backend/.env
    fi
    
    echo "Please edit ./backend/.env to add your API key before continuing."
    exit 1
fi

# Install dependencies if node_modules doesn't exist
if [ ! -d "./backend/node_modules" ]; then
    echo "Installing backend dependencies..."
    cd backend && npm install
    cd ..
fi

# Start the backend server in the background
echo "Starting backend server..."
cd backend && npm start &
BACKEND_PID=$!

# Wait for backend to start
echo "Waiting for backend server to start..."
sleep 3

# Start a simple HTTP server for the frontend
echo "Starting HTTP server for frontend..."
npx http-server -p 8080 &
HTTP_SERVER_PID=$!

echo "Demo is running!"
echo "Backend API: http://localhost:3000"
echo "Frontend: http://localhost:8080"
echo "Open one of the following URLs in your browser:"
echo "- http://localhost:8080/interactive_demo.html (Billing Assistant)"
echo "- http://localhost:8080/hr_interactive_demo.html (HR Assistant)"
echo ""
echo "Press Ctrl+C to stop the servers"

# Handle Ctrl+C to stop both servers
trap "kill $BACKEND_PID $HTTP_SERVER_PID; exit" INT

# Keep the script running
wait
