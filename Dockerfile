# Use an official Python runtime as a parent image
FROM python:3.12-slim

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    mdbtools \
    && rm -rf /var/lib/apt/lists/*

# Copy the .mdb file into the container
COPY /SuperABS_DB.mdb /app/SuperABS_DB.mdb

# Copy the current directory contents into the container at /app
COPY . /app

# Install specific versions of Flask and Werkzeug
RUN pip install --no-cache-dir Flask==2.0.3 Werkzeug==2.0.3

# Install any other needed packages specified in requirements.txt
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Define environment variable
ENV FLASK_APP=app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Run app.py when the container launches
CMD ["flask", "run"]