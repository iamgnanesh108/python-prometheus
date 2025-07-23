# Use an official Python runtime as a parent image
FROM python:3.9-slim-bullseye

# Set the working directory in the container
WORKDIR /app

# Define versions for tools to make them easy to update
ENV PROMETHEUS_VERSION=2.51.2

# --- System Dependencies & Prometheus + Grafana Installation ---
# This single RUN command updates, installs dependencies, and then cleans up.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    gnupg && \
    \
    # Install Prometheus
    wget "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" && \
    tar xvf "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" && \
    mv "prometheus-${PROMETHEUS_VERSION}.linux-amd64" /etc/prometheus && \
    rm "prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz" && \
    \
    # Install Grafana using the new recommended GPG key method
    wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor > /usr/share/keyrings/grafana.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list && \
    \
    # Update package list again and install Grafana
    apt-get update && \
    apt-get install -y grafana && \
    \
    # Clean up APT cache to reduce image size
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Python Application Setup ---
# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application's code
COPY . .

# --- Configuration ---
# Copy Prometheus configuration file
COPY prometheus.yml /etc/prometheus/prometheus.yml

# Copy and set permissions for the entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# --- Port Exposure ---
# Expose ports for Flask, Prometheus, and Grafana
EXPOSE 5000
EXPOSE 9090
EXPOSE 3000

# --- Run the application ---
# Run entrypoint.sh to start all services
ENTRYPOINT ["/app/entrypoint.sh"]
