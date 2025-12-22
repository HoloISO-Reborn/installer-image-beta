#!/bin/bash

# ./build.sh 

usage="""Usage: build.sh [OPTIONS]

OPTION               ( Required / Optional ) Description

Options:
  --help                        ( Optional ) Display this help message
  --images <holoiso-images-dir> ( Required ) Specify the path to the holoiso-images directory
  --branch <branch-name>        ( Required ) Specify the branch name for the build
  --offline                     ( Optional ) Build the installer in offline mode (default)
  --online                      ( Optional ) Build the installer in online mode
  --type                        ( Optional ) Specify the type of installer to build (default: full; full, online)
  --clean                       ( Optional ) Clean up temporary files after build
  --output-dir <output-dir>     ( Optional ) Specify the output directory for the built installer (default: out/<branch-name>)
"""

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
        --type)
            TYPE="$2"
            if [[ "$TYPE" != "full" && "$TYPE" != "online" ]]; then
                echo "Invalid type specified. Allowed values are 'full' or 'online'."
                exit 1
            fi
            shift
            shift
            ;;
        --help)
            echo $usage
            shift
            exit 0
            ;;
        *)
        echo "Unknown flag: $1\n For usage, use --help"
        exit 1
        ;;
    esac
done
if [[ -z "${TYPE}" ]]; then
    TYPE="full"
fi
if [[ -z "${output_dir}" ]]; then
    output_dir="out/${BRANCH}"
fi
# prep
echo "Preparing..."
mkdir -p $output_dir
rm -rf ${script_path}/airootfs/etc/holoinstall/*zst
mkdir -p ${script_path}/airootfs/etc/holoinstall

if [ "$TYPE" == "online" ]; then
    echo "Building in online installer. NOTE: Comming soon"
    echo "online" > ${script_path}/airootfs/etc/installer_type
    echo ${BRANCH} > ${script_path}/airootfs/etc/installer_branch
    IMAGEFILE="holoiso_${BRANCH}_online"
elif [ "$TYPE" == "full" ]; then
    if [ "$offline" = true ]; then
        if [[ -z "${holoiso_images_dir}" ]]; then
            echo "Please provide holoiso-images directory path using --images"
            exit 1
        fi
        echo "Using holoiso-images from: ${holoiso_images_dir}"
        source  ${holoiso_images_dir}/latest_$BRANCH.releasemeta
        cp ${holoiso_images_dir}/${IMAGEFILE}.img.zst ${script_path}/airootfs/etc/holoinstall
    else
        echo "Building in online mode. NOTE: Comming soon"
    fi
fi
# Sets the iso name in /profiledef.sh
echo ${IMAGEFILE} > /tmp/currentcandidate

echo "Starting build"

# ACTUALL BUILD
sudo mkarchiso -v -w ${work} -o ${output_dir} ${script_path}

#!/bin/bash

# Directory containing the ISO files (default to current directory)
DIR=$output_dir

# Loop through all .iso files in the directory
for iso in "$DIR"/*.iso; do
    # Skip if no .iso files are found
    [ -e "$iso" ] || continue

    # Check if the corresponding .sha256 file exists
    if [ ! -f "$iso.sha256" ]; then
        # Generate the SHA-256 checksum and save it to a .sha256 file
        sha256sum "$iso" > "$iso.sha256"
        echo "Generated SHA-256 checksum for $iso"
    else
        echo "SHA-256 checksum already exists for $iso"
    fi
done

if [ "$clean" == true ]; then
    echo "Cleaning..."
    rm -rf ${script_path}/airootfs/etc/holoinstall/*zst
    rm -rf ${work}
fi
