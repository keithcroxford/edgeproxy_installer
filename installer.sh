#!/bin/sh
BASE_DIR="/usr/src"
KAMAILIO_COMMIT="9e70e8ec1a80787cfafc63ea0200766e385ae022"
LIST_OF_APPS="vim git gcc g++ flex bison  make cmake libssl-dev libcurl4-openssl-dev libxml2 libpcre3 debhelper default-libmysqlclient-dev gperf iptables-dev libavcodec-dev libavfilter-dev libavformat-dev libavutil-dev libbencode-perl libcrypt-openssl-rsa-perl libcrypt-rijndael-perl libhiredis-dev libio-multiplex-perl libio-socket-inet6-perl libjson-glib-dev libdigest-crc-perl libdigest-hmac-perl libnet-interface-perl libnet-interface-perl libssl-dev libsystemd-dev libxmlrpc-core-c3-dev libcurl4-openssl-dev libevent-dev libpcap0.8-dev markdown unzip nfs-common dkms libspandsp-dev"

# Use APT and obtain the reqs for installation
echo "Installing pre-reqs"
apt-get update
apt-get install -y "$LIST_OF_APPS"

#Git Kamailio
cd $BASE_DIR
echo "Installing Kamailio"
if [ ! -d "$BASE_DIR/kamailio" ]; then
    git clone https://github.com/kamailio/kamailio.git
    cd $BASE_DIR/kamailio
    git checkout $KAMAILIO_COMMIT
    make
    make install
    echo "adding scripts to /etc/kamailio"
    if [ ! -d "/etc/kamailio" ]; then
        mkdir /etc/kamailio
        cp $BASE_DIR/kamailio/etc/* /etc/kamailio
    else
        while true; do
	    read -d "Do you want to overwrite /etc/kamailio and copy the default script?" yn	
	    case $yn in
	        [Yy] ) mkdir /etc/kamailio; cp $BASE_DIR/kamailio/etc/kamailio.cfg /etc/kamailio;;
                [Nn] ) echo "Skipping";;
		* ) echo "Please answer Y or N";;
	    esac
        done	    
    fi
fi 


# Obtain G.729 for RTPEngine
if [ ! -d "$BASE_DIR/g729" ]; then
    mkdir $BASE_DIR/g729
    export DEB_BUILD_OPTIONS=nocheck
    cd $BASE_DIR/g729
    echo "Installing G729"
    wget https://deb.sipwise.com/spce/mr6.2.1/pool/main/b/bcg729/libbcg729-0_1.0.4+git20180222-0.1~bpo9+1_amd64.deb
    wget https://deb.sipwise.com/spce/mr6.2.1/pool/main/b/bcg729/libbcg729-dev_1.0.4+git20180222-0.1~bpo9+1_amd64.deb
    dpkg -i libbcg729-0_1.0.4+git20180222-0.0~bpo9+1_amd64.deb
    dpkg -i libbcg729-dev_1.0.4+git20180222-0.1~bpo9+1_amd64.deb
fi

cd $BASE_DIR

#Now install RTPEngine
echo "installing RTPEngine"
#https://github.com/sipwise/rtpengine/issues/459 <- follow this
if [ ! -d "$BASE_DIR/rtpengine" ]; then
    git clone https://github.com/sipwise/rtpengine.git
    cd $BASE_DIR/rtpengine
    make 
    make install 
fi
