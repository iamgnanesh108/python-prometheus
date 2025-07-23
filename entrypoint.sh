#!/bin/bash

# Start Prometheus in the background
/etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml &

# Start the Flask application using Gunicorn in the background
# Gunicorn is a production-ready WSGI server
gunicorn --bind 0.0.0.0:5000 app:app &

# Start Grafana in the foreground
# This will keep the container running
/usr/sbin/grafana-server --config=/etc/grafana/grafana.ini --pidfile=/var/run/grafana/grafana-server.pid --packaging=deb cfg:default.paths.logs=/var/log/grafana cfg:default.paths.data=/var/lib/grafana cfg:default.paths.plugins=/var/lib/grafana/plugins
