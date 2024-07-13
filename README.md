# AlphaGeometry Docker Setup

This repository contains the necessary steps to set up and run AlphaGeometry inside a Docker container.

## Prerequisites

- Docker installed on your system. You can follow the instructions below to install Docker.

## Install Docker

### For Ubuntu

1. Update the package index and install packages to allow apt to use a repository over HTTPS: `sudo apt-get update && sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common`
2. Add Docker’s official GPG key: `curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`
3. Set up the stable repository: `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"`
4. Update the package index again and install Docker: `sudo apt-get update && sudo apt-get install -y docker-ce`
5. Verify that Docker is installed correctly by running: `sudo docker run hello-world`

### For Windows and macOS

1. Download and install Docker Desktop from [Docker's official website](https://www.docker.com/products/docker-desktop).
2. Follow the installation instructions provided by the installer.
3. Once installed, verify the installation by opening a terminal (Command Prompt or PowerShell on Windows, Terminal on macOS) and running: `docker run hello-world`

## Build the Docker Image

1. Clone this repository: `git clone https://github.com/google-deepmind/alphageometry.git && cd alphageometry`
2. Save the following Dockerfile in the root of the cloned repository:

    ```dockerfile
    # Use the official Ubuntu base image
    FROM ubuntu:20.04

    # Set the working directory
    WORKDIR /app

    # Update the package lists and install dependencies
    RUN apt-get update && apt-get install -y \
        python3.10 \
        python3.10-venv \
        python3.10-dev \
        git \
        wget \
        curl

    # Install pip
    RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10

    # Clone the AlphaGeometry repository
    RUN git clone https://github.com/google-deepmind/alphageometry.git .

    # Set up a virtual environment and activate it
    RUN python3.10 -m venv venv
    RUN . venv/bin/activate

    # Install the dependencies
    RUN pip install --require-hashes -r requirements.txt

    # Download weights and vocabulary
    RUN bash download.sh

    # Install meliad separately
    RUN mkdir -p meliad_lib/meliad && \
        git clone https://github.com/google-research/meliad meliad_lib/meliad && \
        export PYTHONPATH=$PYTHONPATH:$(pwd)/meliad_lib/meliad

    # Expose any necessary ports (if applicable)
    # EXPOSE 8000

    # Define the entrypoint
    ENTRYPOINT ["/bin/bash"]
    ```

3. Build the Docker image: `docker build -t alphageometry .`

## Run the Docker Container

To run the Docker container in interactive mode, use the following command: `docker run -it alphageometry`

Once inside the container, activate the virtual environment and run AlphaGeometry: `source venv/bin/activate`

Example command to run AlphaGeometry:

```sh
python -m alphageometry --alsologtostderr --problems_file=$(pwd)/imo_ag_30.txt --problem_name=translated_imo_2000_p1 --mode=ddar "${DDAR_ARGS[@]}"
