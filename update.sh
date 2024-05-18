#!/usr/bin/env bash
#
# update the Sensa emoji
#

set -o errexit
set -o pipefail
set -o nounset

if ! [ -x "$(command -v rename)" ]; then
	echo "ERROR: rename is not installed."
    echo "  install with:"
    echo "       ubuntu: sudo apt-get install rename"
    echo "       macosx: brew install rename"
	exit 1
fi

echo "INFO: starting at $(date -u +%Y-%m-%dT%H:%M:%SZ)"

SCRIPT_HOME="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMPFILE="${SCRIPT_HOME}/tmp/sensa-emoji.zip"

if [ ! -f "${TMPFILE}" ]; then
    echo "INFO: downloading Sensa Emoji into ${TMPFILE}"
    mkdir -p "${SCRIPT_HOME}/tmp"
    curl \
        --location \
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
