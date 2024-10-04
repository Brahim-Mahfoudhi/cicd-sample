#!/bin/bash
set -euo pipefail

# Check if the directory 'tempdir' exists
if [[ -d tempdir ]]; then
    echo "Removing existing tempdir..."
    rm -r tempdir
fi 

# Create the necessary directory structure
mkdir -p tempdir/templates tempdir/static

# Copy files into the tempdir
cp sample_app.py tempdir/. || { echo "Failed to copy sample_app.py"; exit 1; }
cp -r templates/* tempdir/templates/. || { echo "Failed to copy template files"; exit 1; }
cp -r static/* tempdir/static/. || { echo "Failed to copy static files"; exit 1; }

# Create the Dockerfile
cat > tempdir/Dockerfile << _EOF_
FROM python
RUN pip install flask
COPY ./static /home/myapp/static/
COPY ./templates /home/myapp/templates/
COPY sample_app.py /home/myapp/
EXPOSE 5050
CMD python /home/myapp/sample_app.py
_EOF_

# Navigate to tempdir
cd tempdir || { echo "Failed to navigate to tempdir"; exit 1; }

# Stop and remove the Docker container if it exists
if [[ "$(docker ps -aq -f name=samplerunning)" ]]; then
    echo "Stopping and removing existing container 'samplerunning'..."
    docker stop samplerunning || { echo "Failed to stop container"; exit 1; }
    docker rm samplerunning || { echo "Failed to remove container"; exit 1; }
fi

# Build the Docker image
docker build -t sampleapp . || { echo "Docker build failed"; exit 1; }

# Run the Docker container
docker run -t -d -p 5050:5050 --name samplerunning sampleapp || { echo "Failed to run Docker container"; exit 1; }

# List running containers
docker ps -a
