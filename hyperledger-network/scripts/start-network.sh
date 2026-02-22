#!/bin/bash

echo "Starting Hyperledger Fabric network..."

# Change to the network directory
cd "$(dirname "$0")/.."

echo "Building Docker images (if needed)..."
cd docker
docker-compose up -d

echo "Waiting for network to start..."
sleep 10

echo "Network started successfully!"
echo "You can now create channels and deploy chaincode."
echo ""
echo "To create a channel, run: ./scripts/create-channel.sh"
echo "To stop the network, run: ./scripts/stop-network.sh"