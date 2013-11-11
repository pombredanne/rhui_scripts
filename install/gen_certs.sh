#!/bin/sh
source ./hostnames
source ./vars

mkdir ~/rhui_certs
cd ~/rhui_certs
echo "Will generate certs for: "
echo "  RHUA   = ${RHUA}"
echo "  CDS_01 = ${CDS_01}"
echo "  CDS_02 = ${CDS_02}"
/usr/share/rh-rhua/create_rhui_ssl_certs.sh --noencrypt ${RHUA} ${CDS_01} ${CDS_02}

