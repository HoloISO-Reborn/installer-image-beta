#!/bin/bash

# ./build.sh 

#VARS
_SCRIPT=$(realpath "$0")
script_path=$(dirname "$_SCRIPT")
work="/tmp/$(date +%Y%m%d.%H%M.%S)"

offline=true
clean=false

# Parse flags if provided
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --offline)
            offline=true
            shift
            ;;
        --online)
            offline=false
            shift
            ;;
        --clean)
            clean=true
            shift
            ;;
        --images)
            holoiso_images_dir="$2"
            if [[ -z "${holoiso_images_dir}" ]]; then
                echo "Please provide a valid holoiso-images directory path after --images"
                exit 1
            fi
            shift
            shift
            ;;
        --branch)
            BRANCH="$2"
            if [[ -z "${BRANCH}" ]]; then
                echo "Please provide a valid branch name after --branch"
                exit 1
            fi
            shift
            shift
            ;;
        --output-dir)
            output_dir="$2"
            shift
            shift
            ;;
        *)
        echo "Unknown flag: $1"
        exit 1
        ;;
    esac
done

if [[ -z "${output_dir}" ]]; then
    output_dir="out/${BRANCH}"
fi
# prep
mkdir -p $output_dir
rm -rf ${script_path}/airootfs/etc/holoinstall/*zst
mkdir -p ${script_path}/airootfs/etc/holoinstall

if [ "$offline" = true ]; then
    if [[ -z "${holoiso_images_dir}" ]]; then
        echo "Please provide holoiso-images directory path using --images"
        exit 1
    fi
    source  ${holoiso_images_dir}/latest_$BRANCH.releasemeta
    cp ${holoiso_images_dir}/${IMAGEFILE}.img.zst ${script_path}/airootfs/etc/holoinstall
    echo "Building in offline mode."
else
    echo "Building in online mode. NOTE: Comming soon"
fi

# Sets the iso name in /profiledef.sh
echo ${IMAGEFILE} > /tmp/currentcandidate

# ACTUALL BUILD
sudo mkarchiso -v -w ${work} -o ${output_dir} ${script_path}

if [ "$clean" == true ]; then
    rm -rf ${script_path}/airootfs/etc/holoinstall/*zst
    rm -rf ${work}
fi
