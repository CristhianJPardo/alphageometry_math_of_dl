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
