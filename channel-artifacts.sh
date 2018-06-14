#!/bin/sh


CHANNEL_NAME="default"
PROJPATH=$(pwd)
CHANNELPATH=$PROJPATH/artifacts/channel
mkdir $CHANNELPATH

echo
echo "##########################################################"
echo "#########  Generating Orderer Genesis block ##############"
echo "##########################################################"
$PROJPATH/configtxgen -profile OneOrgGenesis -outputBlock $CHANNELPATH/genesis.block

echo
echo "#################################################################"
echo "### Generating channel configuration transaction 'channel.tx' ###"
echo "#################################################################"
$PROJPATH/configtxgen -profile OneOrgChannel -outputCreateChannelTx $CHANNELPATH/channel.tx -channelID $CHANNEL_NAME
cp $CHANNELPATH/channel.tx $PROJPATH/web

echo
echo "#################################################################"
echo "####### Generating anchor peer update for ThanksOrg ##########"
echo "#################################################################"
$PROJPATH/configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate $CHANNELPATH/ThanksOrgMSPAnchors.tx -channelID $CHANNEL_NAME -asOrg ThanksOrgMSP