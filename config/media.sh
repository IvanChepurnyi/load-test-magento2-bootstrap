#!/usr/bin/env bash

if [ $# -lt 3 ]; then
    echo "Usage: ./media.sh magento_root_path media_set_file media_path"
    echo ""
    echo "Example:"
    echo "  ./media.sh /var/www/html media.set /path/to/media";
    exit 1;
fi

MAGE_PATH=$1
IMG_INPUT=$2
IMG_SOURCE=$3

check_args () {
    if [ ! -d ${MAGE_PATH} ]; then
        echo "ERROR: Entered Magento root directory does not exist";
        exit 1;
    fi

    if [ ! -f ${IMG_INPUT} ]; then
        echo "ERROR: Entered media set file does not exist";
        exit 1;
    fi

    if [ ! -d ${IMG_SOURCE} ]; then
        echo "ERROR: Entered media directory does not exist";
        exit 1;
    fi

    IMG_SOURCE=$(readlink -e ${IMG_SOURCE})
}

process () {
    while IFS= read -r IMG_FILE
    do
        MEDIA_PATH="${MAGE_PATH}/media"
        IMG_PATH="${MEDIA_PATH}/catalog/product${IMG_FILE:0:4}"
        if [ ! -d "${IMG_PATH}" ]; then
            mkdir -p ${IMG_PATH}
        fi

        RND=$(printf '%02d' $(((RANDOM % 24) + 1)));

        ln -fs "${IMG_SOURCE}/0${RND}.jpg" "${MEDIA_PATH}/catalog/product${IMG_FILE}"
    done < "${IMG_INPUT}"
}

check_args;
process;
