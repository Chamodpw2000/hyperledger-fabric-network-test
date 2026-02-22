#!/bin/bash

echo "=========================================="
echo "Hyperledger Fabric Network Setup Script"
echo "=========================================="
echo ""

# Change to the network directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NETWORK_DIR="$(dirname "$SCRIPT_DIR")"
cd "$NETWORK_DIR"

echo "Network directory: $NETWORK_DIR"
echo ""

# Step 1: Generate crypto materials
echo "Step 1: Generating crypto materials and channel artifacts..."
if [ ! -d "crypto-config" ]; then
    ./scripts/generate-crypto.sh
    if [ $? -eq 0 ]; then
        echo "✓ Crypto materials generated successfully"
    else
        echo "✗ Failed to generate crypto materials"
        exit 1
    fi
else
    echo "✓ Crypto materials already exist"
fi
echo ""

# Step 2: Start the network
echo "Step 2: Starting the Hyperledger Fabric network..."
./scripts/start-network.sh
if [ $? -eq 0 ]; then
    echo "✓ Network started successfully"
else
    echo "✗ Failed to start network"
    exit 1
fi
echo ""

# Wait for network to fully initialize
echo "Waiting for network to initialize..."
sleep 15

# Step 3: Create and join channel
echo "Step 3: Creating and joining channel..."
./scripts/create-channel.sh
if [ $? -eq 0 ]; then
    echo "✓ Channel created and peers joined successfully"
else
    echo "✗ Failed to create channel"
    exit 1
fi
echo ""

# Step 4: Deploy chaincode
echo "Step 4: Deploying sample chaincode..."
./scripts/deploy-chaincode.sh
if [ $? -eq 0 ]; then
    echo "✓ Chaincode deployed successfully"
else
    echo "✗ Failed to deploy chaincode"
    exit 1
fi
echo ""

echo "=========================================="
echo "🎉 Hyperledger Fabric Network Setup Complete!"
echo "=========================================="
echo ""
echo "Your network is now running with:"
echo "  - 1 Orderer node"
echo "  - 4 Peer nodes (2 per organization)"
echo "  - 1 Channel (mychannel)"
echo "  - Sample asset management chaincode deployed"
echo ""
echo "Next steps:"
echo "  - Query assets: ./scripts/query-assets.sh"
echo "  - Stop network: ./scripts/stop-network.sh"
echo ""
echo "Network endpoints:"
echo "  - Orderer: localhost:7050"
echo "  - Org1 Peer0: localhost:7051"
echo "  - Org1 Peer1: localhost:8051"
echo "  - Org2 Peer0: localhost:9051"
echo "  - Org2 Peer1: localhost:10051"