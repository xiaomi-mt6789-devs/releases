#!/usr/bin/env bash

set -euo pipefail

SCRIPT_ROOT="$(realpath "$(dirname "${0}")")"

META="$(mktemp)" # Will be filled META-INF/com/android/metadata

getMetadataProp()
{
    PROPNAME="${1}"
    awk -F "=" "{ if (\$1 == \"${PROPNAME}\") print \$2 }" "${META}"
}

OTA="${1}"
INIT="false"
if [[ $# -gt 1 ]] && [[ "${2}" == "--init" ]]; then
    INIT="true"
fi

if [[ ! -f "${1}" ]]
then
    echo "Zip not found, bruh!"
fi

if [[ "${INIT}" == "true" ]];
then
    echo "- Initialising OTA dir for ${1}"
else
    echo "- Generating LineageOS OTA for ${1}"
fi

echo "-- Writing metatada in ${META}"

unzip -p "${OTA}" "META-INF/com/android/metadata" > "${META}"

DEVICE="$(getMetadataProp "pre-device" | cut -d "," -f1)" # Primary codename should always be the first in TARGET_OTA_ASSERT_DEVICE list
SDK="$(getMetadataProp "post-sdk-level")"
INCR="$(getMetadataProp "post-build-incremental")"
TS="$(getMetadataProp "post-timestamp")"
BUILD_DATE="$(date --date="@${TS}" +%Y%m%d)"

echo "-- Device: ${DEVICE}"
echo "-- SDK: ${SDK}"
echo "-- Incremental: ${INCR}"
echo "-- Build timestamp: ${TS} (date ${BUILD_DATE})"

LINEAGE_VER=""

case "${SDK}" in
    30)
        LINEAGE_VER="18.1"
        ;;
    32)
        LINEAGE_VER="19.1"
        ;;
    33)
        LINEAGE_VER="20.0"
        ;;
    *)
        echo "Unknown sdk ver"
        exit 1
esac

VER_FILENAME="lineage-${LINEAGE_VER}-${BUILD_DATE}-UNOFFICIAL-${DEVICE}.zip"

echo "-- Lineage ver: ${LINEAGE_VER}"
echo "-- Finished reading props"

if [[ "${INIT}" == "false" ]]; then
    echo "-- Updating old ota jsons"
    LATEST_INCR="$(ls "${DEVICE}" | tail -1)"
    
    if [ "${LATEST_INCR/.json/}" == "${INCR}" ]; then
        echo "-- Latest incremental matches incremental, this is probably an error."
        exit 1
    fi

    echo "-- Latest incremntal: ${LATEST_INCR}"
    cat << EOF > "${DEVICE}/${LATEST_INCR}"
{
    "response": [
        {
            "datetime": ${TS},
            "filename": "${VER_FILENAME}",
            "id": "$(md5sum "${OTA}" | awk '{print $1}')",
            "romtype": "unofficial",
            "size": "$(stat -c%s "${OTA}")",
            "url": "https://github.com/xiaomi-mt6789-devs/releases/releases/download/${TS}/${VER_FILENAME}",
            "version": "${LINEAGE_VER}"
        }
    ]
}
EOF
    echo "-- Checking JSON"
    jq -r . "${DEVICE}/${LATEST_INCR}"
    echo "-- JSON is Valid"
    git add "${DEVICE}/${LATEST_INCR}"
fi

echo "-- Writing new OTA json"

JSON_PATH="${DEVICE}/${INCR}.json"

mkdir -p "${DEVICE}"

cat << EOF > "${JSON_PATH}"
{
    "response": []
}
EOF

echo "-- Generated ${JSON_PATH}"

echo "-- Making sure json seems valid"
jq -r . "${JSON_PATH}"
echo "-- Valid JSON"
git add "${JSON_PATH}"

echo "-- Commiting changes"
if [ "$INIT" == "true" ];
then
    git commit -sm "${DEVICE}: Initial OTA repository"
else
    git commit -sm "${DEVICE}: Update ${LATEST_INCR} to ${INCR}"
fi

echo "-- Adding upload files"
mkdir -p "upload"

cp "${OTA}" "upload/${VER_FILENAME}"
# Also add boot.img
payload-dumper-go -p boot,vendor_boot -o "upload" "${OTA}"
mv "upload/boot.img" "upload/boot-${VER_FILENAME/.zip/.img}"
mv "upload/vendor_boot.img" "upload/vendor_boot-${VER_FILENAME/.zip/.img}"

echo "-- Generating release notes to STDOUT"

DEVICE="${DEVICE}" INIT="${INIT}" LINEAGE_VER="${LINEAGE_VER}" BUILD_DATE="${BUILD_DATE}" "${SCRIPT_ROOT}/release_notes.sh"

