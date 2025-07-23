from flask import Flask, Response
from prometheus_flask_exporter import PrometheusMetrics

# Initialize Flask app
app = Flask(__name__)

# Initialize Prometheus metrics for Flask
# This will expose a /metrics endpoint
metrics = PrometheusMetrics(app)

# A simple static info metric
metrics.info('app_info', 'Application info', version='1.0.0')

@app.route('/')
def hello():
    """A simple endpoint to generate some traffic."""
    return "Hello, World!"

@app.route('/status/<code>')
def status_code(code):
    """An endpoint to test different status codes."""
    try:
        status_code = int(code)
        return Response(f"Responding with status code: {status_code}", status=status_code)
    except ValueError:
        return Response("Invalid status code provided.", status=400)

if __name__ == '__main__':
    # Run the app on port 5000, accessible from any IP address
    app.run(host='0.0.0.0', port=5000)
