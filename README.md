# Prompt Engineering Implementation

This project demonstrates two prompt engineering use cases:

1. **Billing Assistant**: Enhancing a basic prompt for a SaaS billing support assistant using the CLEAR framework and Chain-of-Thought prompting.
2. **HR Assistant**: Restructuring an HR assistant prompt to improve security and caching efficiency.

## Project Structure

```
.
├── backend/                  # Backend API for the demos
│   ├── server.js             # Express server with API endpoints
│   ├── package.json          # Node.js dependencies
│   └── .env.example          # Environment variables template
├── interactive_demo.html     # Billing Assistant interactive demo
├── hr_interactive_demo.html  # HR Assistant interactive demo
└── README.md                 # This file
```

## Setup Instructions

### Prerequisites

- Node.js (v14 or higher) - *not needed if using Docker*
- npm (v6 or higher) - *not needed if using Docker*
- OpenAI API key
- Docker and Docker Compose (optional)

### Docker Setup (Recommended)

1. Make sure Docker and Docker Compose are installed on your system.

2. Run the application using the provided script:
   ```
   ./docker-run.sh
   ```

   Or manually with Docker Compose:
   ```
   docker-compose up --build
   ```

3. Access the demos in your browser:
   - Billing Assistant: http://localhost:8080/interactive_demo.html
   - HR Assistant: http://localhost:8080/hr_interactive_demo.html

The Docker setup automatically uses the Azure OpenAI configuration from the `backend/.env` file.

### Quick Start (Without Docker)

#### Using the Start Scripts

1. For Unix/Linux/Mac users:
   ```
   ./start.sh         # Standard OpenAI API
   ```
   Or for Azure OpenAI:
   ```
   ./start.sh --azure # Azure OpenAI API
   ```

2. For Windows users:
   ```
   start.bat          # Standard OpenAI API
   ```
   Or for Azure OpenAI:
   ```
   start.bat --azure  # Azure OpenAI API
   ```

These scripts will:
- Check for Node.js and npm
- Create a `.env` file if it doesn't exist
- Install dependencies
- Start the backend server
- Start a simple HTTP server for the frontend
- Open the demos in your browser

### Manual Setup

#### Backend Setup

1. Navigate to the backend directory:
   ```
   cd backend
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Create a `.env` file from the example:
   ```
   cp .env.example .env
   ```

4. Edit the `.env` file and add your OpenAI API key and model:
   ```
   # For standard OpenAI API
   OPENAI_API_KEY=your_openai_api_key_here
   OPENAI_MODEL_ID=gpt-4o
   ```

   Or for Azure OpenAI (a sample file is provided at `backend/.env.azure`):
   ```
   OPENAI_API_KEY=your_azure_openai_api_key
   OPENAI_API_TYPE=azure
   OPENAI_API_BASE=https://hai-build-enablement.openai.azure.com/
   OPENAI_API_VERSION=2023-05-15
   OPENAI_MODEL_ID=gpt-4o  # or gpt-4o-mini
   ```
   
   You can copy the Azure configuration file:
   ```
   cp backend/.env.azure backend/.env
   ```
   Then edit it to add your API key.

5. Start the server:
   ```
   npm start
   ```

   The server will run on http://localhost:3000 by default.

#### Running the Demos

1. With the backend server running, open either of the HTML files in your browser:
   - `interactive_demo.html` for the Billing Assistant demo
   - `hr_interactive_demo.html` for the HR Assistant demo

2. You can also use a simple HTTP server to serve the HTML files:
   ```
   npx http-server -p 8080
   ```
   Then navigate to http://localhost:8080 in your browser.

## Using the Demos

### Billing Assistant Demo

The Billing Assistant demo showcases two prompt approaches:

1. **Standard Prompt**: A refined prompt using the CLEAR framework
2. **Chain-of-Thought Prompt**: An enhanced prompt that shows the reasoning process

You can:
- View pre-defined scenarios (Refund Eligibility, Unexpected Charges, Late Payment Fees)
- Try your own queries in the Interactive Demo tab
- Choose which prompt type to use or let the system auto-select based on query complexity

### HR Assistant Demo

The HR Assistant demo compares two prompt approaches:

1. **Original Prompt**: An insecure prompt that includes sensitive information
2. **Secured Prompt**: A layered architecture prompt with security enhancements

You can:
- View pre-defined scenarios (Leave Balance, Password Reset, Policy Question)
- Try your own queries in the Interactive Demo tab
- Test prompt injection attacks and see how the secured prompt prevents them

## Implementation Details

### Billing Assistant

- Uses the CLEAR framework (Contextualized, Logical, Explicit, Actionable, Relevant)
- Implements Chain-of-Thought prompting for complex queries
- Automatically selects the appropriate prompt based on query complexity
- Formats the analysis section for better readability

### HR Assistant

- Implements a layered prompt architecture with clear boundaries
- Removes sensitive information (especially passwords) from the prompt
- Adds explicit security rules with highest priority
- Includes input sanitization to detect and prevent prompt injection
- Implements response filtering to prevent information leakage

## Security Considerations

- The HR Assistant demo intentionally includes an insecure prompt option for educational purposes
- In a production environment, only the secured prompt should be used
- The backend includes additional security measures like input sanitization and response filtering

## Docker Configuration

The project includes Docker configuration files for easy deployment:

- `Dockerfile`: Configures the Node.js environment for both backend and frontend
- `docker-compose.yml`: Sets up the services with proper port mappings and environment variables
- `docker-run.sh`: Helper script to run the Docker setup

The Docker setup mounts the `backend/.env` file into the container, so any changes to this file will be reflected when you restart the container.

To stop the Docker containers, press `Ctrl+C` in the terminal where they're running.
