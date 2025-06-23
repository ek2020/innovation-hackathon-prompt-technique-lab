@echo off
echo Starting Prompt Engineering Demo...

REM Check for command line arguments
set USE_AZURE=false
if "%1"=="--azure" (
    set USE_AZURE=true
    echo Using Azure OpenAI configuration...
)

REM Check if Node.js is installed
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Node.js is not installed. Please install Node.js to run this demo.
    exit /b 1
)

REM Check if npm is installed
where npm >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo npm is not installed. Please install npm to run this demo.
    exit /b 1
)

REM Check if .env file exists in backend directory
if not exist ".\backend\.env" (
    echo No .env file found in backend directory.
    
    if "%USE_AZURE%"=="true" if exist ".\backend\.env.azure" (
        echo Creating .env file from .env.azure...
        copy ".\backend\.env.azure" ".\backend\.env" >nul
        echo .env file created. Please edit it to add your Azure OpenAI API key.
    ) else if exist ".\backend\.env.example" (
        echo Creating .env file from .env.example...
        copy ".\backend\.env.example" ".\backend\.env" >nul
        echo .env file created. Please edit it to add your OpenAI API key.
    ) else (
        echo No template files found. Creating a new .env file...
        echo # OpenAI API Configuration> ".\backend\.env"
        echo OPENAI_API_KEY=your_openai_api_key_here>> ".\backend\.env"
        echo OPENAI_MODEL_ID=gpt-4o>> ".\backend\.env"
        echo.>> ".\backend\.env"
        echo # For Azure OpenAI (uncomment and fill these if using Azure)>> ".\backend\.env"
        echo # OPENAI_API_TYPE=azure>> ".\backend\.env"
        echo # OPENAI_API_BASE=https://hai-build-enablement.openai.azure.com/>> ".\backend\.env"
        echo # OPENAI_API_VERSION=2023-05-15>> ".\backend\.env"
        echo.>> ".\backend\.env"
        echo # Server Port>> ".\backend\.env"
        echo PORT=3000>> ".\backend\.env"
    )
    
    echo Please edit .\backend\.env to add your API key before continuing.
    exit /b 1
)

REM Install dependencies if node_modules doesn't exist
if not exist ".\backend\node_modules\" (
    echo Installing backend dependencies...
    cd backend && npm install && cd ..
)

REM Start the backend server in a new window
echo Starting backend server...
start cmd /k "cd backend && npm start"

REM Wait for backend to start
echo Waiting for backend server to start...
timeout /t 3 >nul

REM Start a simple HTTP server for the frontend in a new window
echo Starting HTTP server for frontend...
start cmd /k "npx http-server -p 8080"

echo Demo is running!
echo Backend API: http://localhost:3000
echo Frontend: http://localhost:8080
echo Open one of the following URLs in your browser:
echo - http://localhost:8080/interactive_demo.html (Billing Assistant)
echo - http://localhost:8080/hr_interactive_demo.html (HR Assistant)
echo.
echo Close the command windows to stop the servers
