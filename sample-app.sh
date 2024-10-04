 #!/bin/bash
set -euo pipefail

# Check if the directory 'tempdir' exists
if [ ! -d "tempdir" ]; then
    # Create the necessary directories
    mkdir tempdir
    mkdir tempdir/templates
    mkdir tempdir/static

    # Copy files into the tempdir
    cp sample_app.py tempdir/.
    cp -r templates/* tempdir/templates/.
    cp -r static/* tempdir/static/.

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

    # Navigate to tempdir and build the Docker image
    cd tempdir || exit
    docker build -t sampleapp .

    # Run the Docker container
    docker run -t -d -p 5050:5050 --name samplerunning sampleapp
    docker ps -a
else
    echo "Directory 'tempdir' already exists."
    # Optionally: clear the contents or take other actions
    # rm -rf tempdir/*
fi
