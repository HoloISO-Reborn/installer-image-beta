#!/bin/bash

# ./getlatestbuild.sh <branch>
# Branch: holoiso-images/latest_$BRANCH.releasemeta - downloads the branch from source

SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
DOWNLOADPATH=${SCRIPTPATH}/airootfs/etc/holoinstall
#downloadendpoint=https://cd2.holoiso.ru.eu.org/holoiso-images
downloadendpoint=http://109.164.107.149/holoiso/holoiso-images
preferred_imgtype=".img.zst"
#endpoint=https://cd2.holoiso.ru.eu.org/holoiso-images/latest_${UPD_BRANCH}.releasemeta
endpoint=http://109.164.107.149/holoiso/holoiso-images/latest_${UPD_BRANCH}.releasemeta
curl -s "${endpoint}" > ${SCRIPTPATH}/buildinfo

source ${SCRIPTPATH}/buildinfo
mkdir -p ${DOWNLOADPATH}
if [[ -f "${DOWNLOADPATH}/${IMAGEFILE}${preferred_imgtype}" ]]; then
    echo "Already there."
else
    wget ${downloadendpoint}/${IMAGEFILE}${preferred_imgtype} -P ${DOWNLOADPATH}
fi
