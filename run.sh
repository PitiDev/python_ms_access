#!/bin/bash

# Exit on any error
set -e

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check if Python is installed
if ! command_exists python3; then
    echo "Python 3 could not be found. Please install it first."
    exit 1
fi

# Check if pip is installed
if ! command_exists pip3; then
    echo "pip3 could not be found. This might be due to an externally managed environment."
    echo "We'll proceed using python3 -m pip instead."
fi

# Check if ngrok is installed
if ! command_exists ngrok; then
    echo "ngrok could not be found. Please install it first."
    echo "Visit https://ngrok.com/download for installation instructions."
    exit 1
fi

# Create and activate virtual environment using venv
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip in the virtual environment
echo "Upgrading pip..."
python3 -m pip install --upgrade pip

# Install requirements
echo "Installing requirements..."
python3 -m pip install -r requirements.txt

# Install mdbtools if not already installed
if ! command_exists mdb-tables; then
    echo "mdbtools not found. Attempting to install..."
    if command_exists apt-get; then
        sudo apt-get update && sudo apt-get install -y mdbtools
    elif command_exists brew; then
        brew install mdbtools
    else
        echo "Unable to install mdbtools automatically. Please install it manually."
        exit 1
    fi
fi

# Run the Flask app
echo "Starting Flask API..."
python3 app.py &
FLASK_PID=$!

# Wait for the Flask app to start
echo "Waiting for Flask app to start..."
sleep 5

# Start ngrok with custom domain
echo "Starting ngrok with custom domain..."
ngrok http --domain=walrus-vital-adversely.ngrok-free.app 9000

# Cleanup: stop the Flask app when ngrok is closed
trap 'kill $FLASK_PID' EXIT