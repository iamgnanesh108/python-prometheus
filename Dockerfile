# Use an official Python runtime as a parent image
FROM python:3.9-slim-bullseye

# Set the working directory in the container
WORKDIR /app

# --- System Dependencies & Prometheus + Grafana Installation ---
# Install wget and other dependencies, then install Prometheus and Grafana
RUN apt-get update && \
    apt-get install -y wget apt-transport-https software-properties-common && \
    \
    # Install Prometheus
    wget https://github.com/prometheus/prometheus/releases/download/v2.37.0/prometheus-2.37.0.linux-amd64.tar.gz && \
    tar xvf prometheus-2.37.0.linux-amd64.tar.gz && \
    mv prometheus-2.37.0.linux-amd64 /etc/prometheus && \
    rm prometheus-2.37.0.linux-amd64.tar.gz && \
    \
    # Install Grafana
    wget -q -O - https://packages.grafana.com/gpg.key | apt-key add - && \
    echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list && \
    apt-get update && \
    apt-get install -y grafana && \
    \
    # Clean up APT cache
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
