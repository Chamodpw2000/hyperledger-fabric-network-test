#!/bin/bash

# Download and install Hyperledger Fabric binaries
echo "Downloading Hyperledger Fabric binaries..."
curl -sSL https://bit.ly/2ysbOFE | bash -s -- 2.5.4 1.5.7

# Export PATH
export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}

echo "Generating crypto materials..."

# Generate crypto materials
cryptogen generate --config=./crypto-config.yaml

# Create channel artifacts directory
mkdir -p channel-artifacts

echo "Generating genesis block..."
# Generate genesis block
configtxgen -profile TwoOrgsOrdererGenesis -channelID system-channel -outputBlock ./channel-artifacts/genesis.block

echo "Generating channel configuration transaction..."
# Generate channel configuration transaction
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID mychannel

echo "Generating anchor peer transactions..."
# Generate anchor peer transactions
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID mychannel -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID mychannel -asOrg Org2MSP

echo "Crypto materials and channel artifacts generated successfully!"