#!/bin/bash

CHANNEL_NAME="mychannel"
DELAY=3
MAX_RETRY=5

echo "Creating and joining channel: $CHANNEL_NAME"

# Function to set environment variables for specific peer
setGlobals() {
    PEER=$1
    ORG=$2
    
    if [ $ORG -eq 1 ]; then
        CORE_PEER_LOCALMSPID="Org1MSP"
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        if [ $PEER -eq 0 ]; then
            CORE_PEER_ADDRESS=peer0.org1.example.com:7051
        else
            CORE_PEER_ADDRESS=peer1.org1.example.com:8051
        fi
    elif [ $ORG -eq 2 ]; then
        CORE_PEER_LOCALMSPID="Org2MSP"
        CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
        CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
        if [ $PEER -eq 0 ]; then
            CORE_PEER_ADDRESS=peer0.org2.example.com:9051
        else
            CORE_PEER_ADDRESS=peer1.org2.example.com:10051
        fi
    fi
}

# Create channel
createChannel() {
    setGlobals 0 1
    
    echo "Creating channel $CHANNEL_NAME..."
    peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    echo "Channel $CHANNEL_NAME created successfully"
}

# Join peers to channel
joinChannel() {
    ORG=$1
    PEER=$2
    setGlobals $PEER $ORG
    
    echo "Joining peer$PEER.org$ORG to channel $CHANNEL_NAME..."
    peer channel join -b $CHANNEL_NAME.block
    
    echo "peer$PEER.org$ORG joined channel $CHANNEL_NAME"
}

# Update anchor peers
updateAnchorPeers() {
    ORG=$1
    setGlobals 0 $ORG
    
    echo "Updating anchor peers for org$ORG..."
    peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org${ORG}MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    echo "Anchor peer updated for org$ORG"
}

# Execute inside CLI container
docker exec cli bash -c "
    export CORE_PEER_TLS_ENABLED=true
    export CORE_PEER_ID=cli
    export GOPATH=/opt/gopath
    export CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
    export FABRIC_LOGGING_SPEC=INFO

    # Create channel
    echo 'Creating channel...'
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    
    peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    # Join Org1 peers
    echo 'Joining Org1 peers to channel...'
    peer channel join -b $CHANNEL_NAME.block
    
    export CORE_PEER_ADDRESS=peer1.org1.example.com:8051
    peer channel join -b $CHANNEL_NAME.block
    
    # Join Org2 peers
    echo 'Joining Org2 peers to channel...'
    export CORE_PEER_LOCALMSPID=Org2MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
    
    peer channel join -b $CHANNEL_NAME.block
    
    export CORE_PEER_ADDRESS=peer1.org2.example.com:10051
    peer channel join -b $CHANNEL_NAME.block
    
    # Update anchor peers
    echo 'Updating anchor peers...'
    export CORE_PEER_LOCALMSPID=Org1MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org1.example.com:7051
    
    peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
    
    export CORE_PEER_LOCALMSPID=Org2MSP
    export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=peer0.org2.example.com:9051
    
    peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
"

echo "Channel operations completed successfully!"