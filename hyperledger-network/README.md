# Hyperledger Fabric Blockchain Network

A complete Hyperledger Fabric blockchain network setup from scratch with a sample asset management chaincode.

## Network Architecture

This network consists of:

- **1 Orderer Organization** (OrdererOrg)
  - 1 Orderer node using Raft consensus
- **2 Peer Organizations** (Org1MSP, Org2MSP)
  - Each organization has 2 peer nodes
  - Total of 4 peer nodes
- **1 Channel** (mychannel)
- **Sample Chaincode** (Asset Transfer Basic)

## Prerequisites

Ensure you have the following installed:

- **Docker** (v20.10+)
- **Docker Compose** (v1.28+)
- **Go** (v1.19+) - for chaincode development
- **Node.js** (v16+) - optional, for client applications
- **jq** - for JSON parsing in scripts

## Quick Start

### 1. One-Command Setup

Run the main setup script to deploy the entire network:

```bash
./setup.sh
```

This script will:
1. Download Hyperledger Fabric binaries
2. Generate crypto materials and channel artifacts
3. Start the Docker containers
4. Create and join the channel
5. Deploy and initialize the sample chaincode

### 2. Manual Step-by-Step Setup

If you prefer to run each step manually:

```bash
# Generate crypto materials
./scripts/generate-crypto.sh

# Start the network
./scripts/start-network.sh

# Create and join channel
./scripts/create-channel.sh

# Deploy sample chaincode
./scripts/deploy-chaincode.sh
```

## Network Management

### Start Network
```bash
./scripts/start-network.sh
```

### Stop Network
```bash
./scripts/stop-network.sh
```

### Clean Network (removes all data)
```bash
./scripts/stop-network.sh
docker system prune -f
docker volume prune -f
```

## Chaincode Interaction

### Query All Assets
```bash
./scripts/query-assets.sh
```

### Create a New Asset
```bash
docker exec cli peer chaincode invoke \\
  -o orderer.example.com:7050 \\
  --ordererTLSHostnameOverride orderer.example.com \\
  --tls \\
  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \\
  -C mychannel \\
  -n basic \\
  --peerAddresses peer0.org1.example.com:7051 \\
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \\
  --peerAddresses peer0.org2.example.com:9051 \\
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \\
  -c '{"function":"CreateAsset","Args":["asset7","purple","20","Alice","1000"]}'
```

### Query Specific Asset
```bash
docker exec cli peer chaincode query \\
  -C mychannel \\
  -n basic \\
  -c '{"function":"ReadAsset","Args":["asset1"]}'
```

### Transfer Asset
```bash
docker exec cli peer chaincode invoke \\
  -o orderer.example.com:7050 \\
  --ordererTLSHostnameOverride orderer.example.com \\
  --tls \\
  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem \\
  -C mychannel \\
  -n basic \\
  --peerAddresses peer0.org1.example.com:7051 \\
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt \\
  --peerAddresses peer0.org2.example.com:9051 \\
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt \\
  -c '{"function":"TransferAsset","Args":["asset1","Bob"]}'
```

## Directory Structure

```
hyperledger-network/
├── crypto-config.yaml          # Crypto configuration
├── configtx.yaml              # Channel configuration
├── setup.sh                   # Main setup script
├── crypto-config/             # Generated crypto materials
├── channel-artifacts/         # Channel configuration artifacts
├── docker/
│   └── docker-compose.yml     # Docker services definition
├── scripts/
│   ├── generate-crypto.sh     # Generate crypto materials
│   ├── start-network.sh       # Start the network
│   ├── stop-network.sh        # Stop the network
│   ├── create-channel.sh      # Create and join channel
│   ├── deploy-chaincode.sh    # Deploy chaincode
│   └── query-assets.sh        # Query chaincode
└── chaincode/
    └── asset-transfer-basic/
        └── chaincode/
            ├── asset-transfer-basic.go
            └── go.mod
```

## Network Endpoints

| Component | Endpoint |
|-----------|----------|
| Orderer | localhost:7050 |
| Org1 Peer0 | localhost:7051 |
| Org1 Peer1 | localhost:8051 |
| Org2 Peer0 | localhost:9051 |
| Org2 Peer1 | localhost:10051 |

## Sample Chaincode Functions

The deployed asset management chaincode supports the following functions:

- `InitLedger()` - Initialize ledger with sample assets
- `CreateAsset(id, color, size, owner, value)` - Create a new asset
- `ReadAsset(id)` - Read an asset by ID
- `UpdateAsset(id, color, size, owner, value)` - Update an existing asset
- `DeleteAsset(id)` - Delete an asset
- `TransferAsset(id, newOwner)` - Transfer asset to a new owner
- `GetAllAssets()` - Get all assets in the ledger
- `AssetExists(id)` - Check if an asset exists

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 7050, 7051, 8051, 9051, 10051 are available
2. **Docker permission issues**: Run `sudo usermod -aG docker $USER` and restart your session
3. **Network cleanup**: Run the stop script and clean Docker system if experiencing issues

### Debug Commands

```bash
# View running containers
docker ps

# View network logs
docker logs orderer.example.com
docker logs peer0.org1.example.com

# Access CLI container
docker exec -it cli bash

# Check channel configuration
docker exec cli peer channel list
```

### Log Levels

To increase logging verbosity, modify the `FABRIC_LOGGING_SPEC` environment variable in the Docker Compose file:

- `INFO` - General information
- `DEBUG` - Detailed debugging information

## Development

### Adding New Organizations

1. Update `crypto-config.yaml` with new organization details
2. Update `configtx.yaml` with new organization configuration
3. Regenerate crypto materials
4. Update Docker Compose file with new peer containers
5. Update channel configuration

### Deploying New Chaincode

1. Place your chaincode in the `chaincode/` directory
2. Update the chaincode path in `deploy-chaincode.sh`
3. Run the deploy script

### Client Applications

You can develop client applications using:
- **Fabric SDK for Node.js**
- **Fabric SDK for Go**
- **Fabric SDK for Java**

## Security Considerations

- All communications use TLS encryption
- MSP (Membership Service Provider) manages identities
- Chaincode runs in isolated Docker containers
- Private keys are stored in crypto-config directory (keep secure)

## Performance Tuning

For production deployments, consider:

- Using external databases (CouchDB) instead of LevelDB
- Implementing proper backup strategies
- Configuring resource limits for containers
- Setting up monitoring and alerting
- Using load balancers for peer endpoints

## Contributing

Feel free to contribute improvements to this network setup by:

1. Forking the repository
2. Making your changes
3. Testing thoroughly
4. Submitting a pull request

## License

This project is licensed under the Apache 2.0 License - see the LICENSE file for details.

## Support

For issues and questions:

- Check the [Hyperledger Fabric documentation](https://hyperledger-fabric.readthedocs.io/)
- Visit the [Hyperledger Discord](https://discord.gg/hyperledger)
- Browse [Stack Overflow Fabric questions](https://stackoverflow.com/questions/tagged/hyperledger-fabric)