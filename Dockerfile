# Use the official Python image as the base image
FROM python:3.9-alpine

# Set environment variables to prevent Python from writing .pyc files and buffering stdout/stderr
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Install necessary packages and dependencies
RUN apk add --no-cache \
    bash \
    gcc \
    musl-dev \
    libffi-dev \
    openssl-dev

# Install required Python libraries
RUN pip install --no-cache-dir \
    paho-mqtt \
    requests \
    urllib3

# Copy application scripts into the container
COPY run.sh /
COPY envoy_to_mqtt_json.py /

# Ensure the main script has execute permissions
RUN chmod +x /run.sh

# Specify the command to run when the container starts
CMD ["/run.sh"]
