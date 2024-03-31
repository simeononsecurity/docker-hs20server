#!/bin/bash

# Function to start Apache2
start_apache() {
    echo "Starting Apache2..."
    service apache2 start
    if [ $? -ne 0 ]; then
        echo "Failed to start Apache2"
        exit 1
    fi
}

# Function to start RADIUS server
start_radius() {
    echo "Starting RADIUS server..."
    /home/user/hs20-server/AS/hostapd -B /home/user/hs20-server/AS/as-sql.conf
    if [ $? -ne 0 ]; then
        echo "Failed to start RADIUS server"
        exit 1
    fi
}

# Function to handle SIGTERM signal
sigterm_handler() {
    echo "SIGTERM signal received, shutting down..."
    # Implement graceful shutdown procedures here if necessary
    service apache2 stop
    # Optionally, kill your RADIUS server if it doesn't exit on its own
    exit 0
}

# Trap SIGTERM
trap 'sigterm_handler' SIGTERM

# Start services
start_apache
start_radius

# Wait indefinitely to keep the container running
# Instead of tailing /dev/null, wait for a signal (which allows for graceful shutdown)
while true; do
    sleep 1 &
    wait $!
done
