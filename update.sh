#!/usr/bin/env bash
#
# update the Sensa emoji
#

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"



echo "INFO: starting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

if [ "${OSTYPE}" == "darwin" ]; then
    if ! [ -x "$(command -v rename)" ]; then
        echo "ERROR: rename is not installed."
        echo "  install with:"
        echo "       brew install rename"
        exit 1
    fi
else
    # use manually download rename from http://plasmasturm.org/code/rename/rename
    export PATH="${SCRIPT_HOME}/tmp:${PATH}"
    if ! [ -x "$(command -v rename)" ]; then
        echo "ERROR: rename is not installed."
        echo "  download from http://plasmasturm.org/code/rename/rename"
        exit 1
    fi
fi

TMPFILE="${SCRIPT_HOME}/tmp/sensa-emoji.zip"

if [ ! -f "${TMPFILE}" ]; then
    echo "INFO: downloading Sensa Emoji into ${TMPFILE}"
    mkdir -p "${SCRIPT_HOME}/tmp"
    curl \
        --location \
        --no-progress-meter \
        --output "${TMPFILE}" \
        "https://github.com/sensadesign/sensaemoji/raw/main/Sensa%20Emoji%20v1.zip"
else
    echo "INFO: Using Sensa Emoji already downloaded in ${TMPFILE}"
fi

DEST_DIR="${SCRIPT_HOME}/docs/images"
if [ -d "${DEST_DIR}" ]; then
    echo "INFO: removing existing images in ${DEST_DIR}"
    rm -f "${DEST_DIR}"/*.svg
else
    echo "INFO: creating images directory ${DEST_DIR}"
    mkdir -p "${DEST_DIR}"
fi

echo "INFO: unzipping Sensa emoji"
mkdir -p "${DEST_DIR}"
unzip -j -q -d "${DEST_DIR}" "${TMPFILE}" "Sensa Emoji v1/svg/*"

echo "INFO: cleaning up file names"
cd "${DEST_DIR}"
rename --transcode utf-8:utf-8 --nows --lower-case --force *.svg

if [ "${GITHUB_ACTIONS:-false}" == "true" ]; then
    git add *.svg
fi

echo "INFO: complete at $(date -u +%Y-%m-%dT%H:%M:%SZ)"
