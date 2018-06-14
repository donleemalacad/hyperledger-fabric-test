#!/bin/sh

# Exit shell if command simple command fails
set -e

echo
echo "#################################################################"
echo "#######        Generating cryptographic material       ##########"
echo "#################################################################"

PROJPATH=$(pwd)
ARTIFACTSPATH=$PROJPATH/artifacts
CRYPTOPATH=$ARTIFACTSPATH/crypto
ORDERERS=$CRYPTOPATH/ordererOrganizations
PEERS=$CRYPTOPATH/peerOrganizations
THANKSPEERPATH=$PROJPATH/crypto/thanksPeer

# Remove any old artifacts
rm -rf $ARTIFACTSPATH

# Generate Crypto Material
$PROJPATH/cryptogen generate --config=$PROJPATH/crypto-config.yaml --output=$CRYPTOPATH

# Generate Channel Artifacts
sh channel-artifacts.sh

# Remove previous or existing certificates
rm -rf $PROJPATH/crypto/orderer
rm -rf $PROJPATH/crypto/thanksPeer

# Create directories required for certificates
mkdir -p $PROJPATH/crypto/orderer/certs
mkdir -p $PROJPATH/crypto/thanksPeer/certs

# Copy {tls, msp, ca, genesis blocks} certificates to respective folder
# Orderer
cp -r $ORDERERS/excite-org/orderers/orderer0/msp $PROJPATH/crypto/orderer/certs
cp -r $ORDERERS/excite-org/orderers/orderer0/tls $PROJPATH/crypto/orderer/certs

# Peers
cp -r $PEERS/thanks-org/peers/thanks-peer/msp $PROJPATH/crypto/thanksPeer/certs
cp -r $PEERS/thanks-org/peers/thanks-peer/tls $PROJPATH/crypto/thanksPeer/certs

# Genesis Block
cp $ARTIFACTSPATH/channel/genesis.block $PROJPATH/crypto/orderer/certs

# Remove if existing ca cert exists
rm -rf $PROJPATH/crypto/orderer/ca-certs
rm -rf $PROJPATH/crypto/thanksPeer/ca-certs

# Create folder for ca certs
mkdir -p $PROJPATH/crypto/thanksPeer/ca-certs/ca
mkdir -p $PROJPATH/crypto/thanksPeer/ca-certs/tls

# Copy required ca files
cp $PEERS/thanks-org/ca/* $PROJPATH/crypto/thanksPeer/ca-certs/ca
cp $PEERS/thanks-org/tlsca/* $PROJPATH/crypto/thanksPeer/ca-certs/tls

# Renaming of generated files to cert and key
mv $PROJPATH/crypto/thanksPeer/ca-certs/ca/*_sk $PROJPATH/crypto/thanksPeer/ca-certs/ca/key.pem
mv $PROJPATH/crypto/thanksPeer/ca-certs/ca/*-cert.pem $PROJPATH/crypto/thanksPeer/ca-certs/ca/cert.pem
mv $PROJPATH/crypto/thanksPeer/ca-certs/tls/*_sk $PROJPATH/crypto/thanksPeer/ca-certs/tls/key.pem
mv $PROJPATH/crypto/thanksPeer/ca-certs/tls/*-cert.pem $PROJPATH/crypto/thanksPeer/ca-certs/tls/cert.pem

# Generate Web Certificates
WEBCERTS=$PROJPATH/web/certs
rm -rf $WEBCERTS
mkdir -p $WEBCERTS
cp $PROJPATH/crypto/orderer/certs/tls/ca.crt $WEBCERTS/ordererOrg.pem
cp $PROJPATH/crypto/thanksPeer/certs/tls/ca.crt $WEBCERTS/thanksOrg.pem
cp $PEERS/thanks-org/users/Admin@thanks-org/msp/keystore/* $WEBCERTS/Admin@thanks-org-key.pem
cp $PEERS/thanks-org/users/Admin@thanks-org/msp/signcerts/* $WEBCERTS/

# Copy docker files
cp $PROJPATH/docker/orderer/Dockerfile $PROJPATH/crypto/orderer
cp $PROJPATH/docker/thanksPeer/Dockerfile $PROJPATH/crypto/thanksPeer
cp -a $PROJPATH/docker/thanksPeerCa/. $PROJPATH/crypto/thanksPeer/ca-certs