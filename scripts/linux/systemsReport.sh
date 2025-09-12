#!/bin/bash

ARCHS="rk3128 rk3326 rk3568 a133 h700 r16 sm8250"

BR_DIR=$1
KNULLI_BINARIES_DIR=$2
if ! test -d "${BR_DIR}"
then
    echo "${0} <BR_DIR>" >&2
    exit 1
fi

# create temporary directory
TMP_DIR="/tmp/br_systemreport_${$}"
mkdir -p "${TMP_DIR}" || exit 1

# create configs files
for ARCH in ${ARCHS}
do
    echo "generating .config for ${ARCH}" >&2
    TMP_CONFIG="${TMP_DIR}/configs_tmp/${ARCH}"
    TMP_CONFIGS="${TMP_DIR}/configs"
    mkdir -p "${TMP_CONFIG}" "${TMP_CONFIGS}" || exit 1

    # generate the defconfig
    "${BR2_EXTERNAL_KNULLI_PATH}/configs/createDefconfig.sh" "${BR2_EXTERNAL_KNULLI_PATH}/configs/knulli-${ARCH}"

    (make O="${TMP_CONFIG}" -C ${BR_DIR} BR2_EXTERNAL="${BR2_EXTERNAL_KNULLI_PATH}" "knulli-${ARCH}_defconfig" > /dev/null) || exit 1
    cp "${TMP_CONFIG}/.config" "${TMP_CONFIGS}/config_${ARCH}" || exit 1
done

# reporting
ES_YML="${BR2_EXTERNAL_KNULLI_PATH}/package/emulationstation/knulli-es-system/es_systems.yml"
EXP_YML="${BR2_EXTERNAL_KNULLI_PATH}/package/emulationstation/knulli-es-system/systems-explanations.yml"
PYGEN="${BR2_EXTERNAL_KNULLI_PATH}/package/emulationstation/knulli-es-system/knulli-report-system.py"
HTML_GEN="${BR2_EXTERNAL_KNULLI_PATH}/package/emulationstation/knulli-es-system/knulli_systemsReport.html"
DEFAULTSDIR="${BR2_EXTERNAL_KNULLI_PATH}/package/system/knulli-configgen/configs"
mkdir -p "${KNULLI_BINARIES_DIR}" || exit 1
echo python "${PYGEN}" "${ES_YML}" "${EXP_YML}" "${DEFAULTSDIR}" "${TMP_CONFIGS}"
python "${PYGEN}" "${ES_YML}" "${EXP_YML}" "${DEFAULTSDIR}" "${TMP_CONFIGS}" > "${KNULLI_BINARIES_DIR}/knulli_systemsReport.json" || exit 1
cp "${HTML_GEN}" "${KNULLI_BINARIES_DIR}" || exit 1

rm -rf "${TMP_DIR}"
exit 0
