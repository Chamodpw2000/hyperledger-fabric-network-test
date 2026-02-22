#!/bin/bash

echo "Stopping Hyperledger Fabric network..."

# Change to the network directory
cd "$(dirname "$0")/.."

echo "Stopping Docker containers..."
cd docker
docker-compose down

echo "Removing chaincode containers and images..."
docker rm -f $(docker ps -aq --filter label=org.hyperledger.fabric.chaincode.id_name) 2>/dev/null || true
docker rmi $(docker images dev-* -q) 2>/dev/null || true

echo "Network stopped successfully!"