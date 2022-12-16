#!/bin/bash
#
# Copyright (C) 2022-2023 TheStrechh (Carlos Arriaga)
#
# Basic scrip for merge CLO
#

# Colors
red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
end=$'\e[0m'

echo "${blu} Initiating... ${end}"
echo

# Fetch CLO tag from user
read -p "${blu}Enter the CodeLinaro tag you want to merge: ${end}" TAG
echo

sleep 1

# Merging
if [[ $2 = "-i" || $2 = "--initial" ]]; then
    INITIAL_MERGE=true
    echo "${blu} Initial merge ${end}"
fi

# qcacld-3.0
function merge_qcacld() {
    echo "${blu} Merging qcacld-3.0"
    if ! git remote add qcacld-3.0 https://git.codelinaro.org/clo/la/platform/vendor/qcom-opensource/wlan/qcacld-3.0; then
        git remote rm qcacld-3.0
        git remote add qcacld-3.0 https://git.codelinaro.org/clo/la/platform/vendor/qcom-opensource/wlan/qcacld-3.0
    fi

    git fetch qcacld-3.0 $TAG

    if [[ ${INITIAL_MERGE} = true ]]; then
        git merge -s ours --no-commit --allow-unrelated-histories FETCH_HEAD
        git read-tree --prefix=drivers/staging/qcacld-3.0 -u FETCH_HEAD
        git commit -m "qcacld-3.0: Merge tag '$TAG'"
        echo "${grn} Merged qcacld-3.0 tag succesfully! ${end}"
    else
        if ! git merge -X subtree=drivers/staging/qcacld-3.0 FETCH_HEAD --log; then
            echo "${red} Merge failed! ${end}" && exit 1
        else
            echo "${grn} Merged qcacld-3.0 tag sucessfully! ${end}"
        fi
    fi
}

# fw-api
function merge_fw_api() {
    echo "${blu} Merging fw-api"
    if ! git remote add fw-api https://git.codelinaro.org/clo/la/platform/vendor/qcom-opensource/wlan/fw-api; then
        git remote rm fw-api
        git remote add fw-api https://git.codelinaro.org/clo/la/platform/vendor/qcom-opensource/wlan/fw-api
    fi

    git fetch fw-api $TAG

    if [[ ${INITIAL_MERGE} = true ]]; then
        git merge -s ours --no-commit --allow-unrelated-histories FETCH_HEAD
        git read-tree --prefix=drivers/staging/fw-api -u FETCH_HEAD
        git commit -m "fw-api: Merge tag '$TAG'"
    echo "Merged fw-api tag succesfully! ${end}"
    else
        if ! git merge -X subtree=drivers/staging/fw-api FETCH_HEAD --log; then
            echo "${red} Merge failed! ${end}" && exit 1
        else
            echo "${grn} Merged fw-api tag sucessfully! ${end}"
        fi
    fi
}

# qca-wifi-host-cmn
function merge_qca_wifi_host_cmn() {
    echo "${blu} Merging qca-wifi-host-cmn"
    if ! git remote add qca-wifi-host-cmn https://git.codelinaro.org/clo/la/platform/vendor/qcom-opensource/wlan/qca-wifi-host-cmn; then
        git remote rm qca-wifi-host-cmn
        git remote add qca-wifi-host-cmn https://git.codelinaro.org/clo/la/platform/vendor/qcom-opensource/wlan/qca-wifi-host-cmn
    fi

    git fetch qca-wifi-host-cmn $TAG

    if [[ ${INITIAL_MERGE} = true ]]; then
        git merge -s ours --no-commit --allow-unrelated-histories FETCH_HEAD
        git read-tree --prefix=drivers/staging/qca-wifi-host-cmn -u FETCH_HEAD
        git commit -m "qca-wifi-host-cmn: Merge tag '$TAG'"
    echo "${grn} Merged qca-wifi-host-cmn tag succesfully! ${end}"
    else
        if ! git merge -X subtree=drivers/staging/qca-wifi-host-cmn FETCH_HEAD --log; then
            echo "${red} Merge failed! ${end}" && exit 1
        else
            echo "${grn} Merged qca-wifi-host-cmn tag sucessfully! ${end}"
        fi
    fi
}

# techpack
function merge_techpack() {
    echo "${blu} Merging techpack"
    if ! git remote add techpack https://git.codelinaro.org/clo/la/platform/vendor/opensource/audio-kernel; then
        git remote rm techpack
        git remote add techpack https://git.codelinaro.org/clo/la/platform/vendor/opensource/audio-kernel
    fi

    git fetch techpack $TAG

    if [[ ${INITIAL_MERGE} = true ]]; then
        git merge -s ours --no-commit --allow-unrelated-histories FETCH_HEAD
        git read-tree --prefix=techpack/audio -u FETCH_HEAD
        git commit -m "techpack: Merge tag '$TAG'"
        echo "${grn} Merged techpack tag succesfully! ${end}"
    else
        if ! git merge -X subtree=techpack/audio FETCH_HEAD --log; then
            echo "${red} Merge failed! ${end}" && exit 1
        else
            echo "${grn} Merged techpack tag sucessfully! ${end}"
        fi
    fi
}

# initialize script
merge_qcacld
merge_fw_api
merge_qca_wifi_host_cmn
merge_techpack

sleep 1

echo
echo "${grn} Merge successfull... ${end}"
