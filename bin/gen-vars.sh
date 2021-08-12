#!/usr/bin/env bash

THE_SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
THE_SCRIPT_DIR="$(cd "$(dirname "${THE_SCRIPT_PATH}")" &> /dev/null && pwd)"
THE_LIB_DIR="${THE_SCRIPT_DIR}/lib"
THE_SAMPLES_DIR="$(realpath "${THE_SCRIPT_DIR}/../samples")"

PYTHON="$(which python)"
[[ -z "${PYTHON}" ]] && PYTHON="$(which python3)"

print_help() {
  if [[ -z "${PYTHON}" ]]; then
    echo "Warning: Could not locate python path!"
    echo
  fi

  while read -r l; do
    [[ -n "${l}" ]] && echo "${l}"
  done <<< "
    Generate vars file. If you generate it into an existing vars file,
    the values of the target file will remain the same.
  "
  echo
  echo "Available options:"

  while read -r l; do
    [[ -n "${l}" ]] && echo "  ${l}"
  done <<< "
    --dry           Dry run flag. Output to stdout, no file writes will be done.
    --format        Format existing variables. No new variables will be added.
    -h, -?, --help  Print this help.
  "

  echo "Demo usage:"
  while read -r l; do
    [[ -n "${l}" ]] && echo "  ${l}"
  done <<< "
    # generate a variables file into './host_vars/apiportal.yml' target file
    $(basename "${THE_SCRIPT_PATH}") ./host_vars/apiportal.yml
    # compare an existing variables file with the
    # one that can be generated
    vimdiff $(basename "${THE_SCRIPT_PATH}") ./host_vars/apiportal.yml <($(basename "${THE_SCRIPT_PATH}") ./host_vars/apiportal.yml --dry)
  "
}

is_dry=0
do_format=0
INVALID=()
# collect options
while [[ ${#} -gt 0 ]]; do
  case "${1}" in
    -h|-\?|--help)
      print_help
      exit
      ;;
    --dry)
      is_dry=1
      ;;
    --format)
      do_format=1
      ;;
    -*)
      INVALID+=("${1}")
      ;;
    *)
      if [[ -z "${TARGET}" ]]; then
        TARGET="${1}"
      else
        INVALID+=("${1}")
      fi
      ;;
  esac

  shift
done

if [[ ${#INVALID[@]} -gt 0 ]]; then
  echo "Invalid parameters:"
  for i in "${!INVALID[@]}"; do
    echo "$((i + 1))) ${INVALID[${i}]}"
  done

  exit 1
fi

if [[ -z "${PYTHON}" ]]; then
  echo "Could not locate python path"
  exit 1
fi

if [[ -z "${TARGET}" ]]; then
  echo "Output target is required!"
  echo
  print_help
  exit 1
fi

if [[ ! -f "${TARGET}" ]] && [[ ${is_dry} -eq 1 ]]; then
  filename="$(cat /dev/urandom | tr -cd 'a-f0-9' | head -c 10)"
  TARGET="/tmp/${filename}"
fi

OUTPUT="${TARGET}"
[[ ${is_dry} -eq 1 ]] && OUTPUT=/dev/stdout

mkdir -p "$(dirname "${TARGET}")"

if [[ ! -f "${TARGET}" ]]; then
  touch "${TARGET}"
fi

TARGET="$(realpath "${TARGET}")"
SOURCE_FILE="${TARGET}"

target_vars="$("${PYTHON}" "${THE_LIB_DIR}/yaml-text-to-vars.py" < "${TARGET}")"
merged_vars="${target_vars}"
if [[ ${do_format} -eq 0 ]]; then
  source_vars="$("${PYTHON}" "${THE_LIB_DIR}/yaml-text-to-vars.py" < "${THE_SAMPLES_DIR}/vars.yml")"
  merged_vars="$("${PYTHON}" "${THE_LIB_DIR}/merge-vars.py" "${source_vars}" "${target_vars}")"
  SOURCE_FILE="${THE_SAMPLES_DIR}/vars.yml"
fi

SOURCE_CONTENT="$(cat "${SOURCE_FILE}")"

while IFS= read -r l; do
  # ignore yaml beginning
  [[ "${l}" == '---' ]] && continue
  # ignore list and dict elements, we'll get them from merged vars
  [[ "${l}" == '-' ]] && continue
  grep -P '^\s+[^#]' <<< "${l}" > /dev/null && continue

  # if it's a comment or an empty line print it out directly
  grep -P '^\s*(#.*)?$' <<< "${l}" > /dev/null && echo "${l}" && continue

  # it's a variable if we hit this line
  var_name="$(grep -Po '^[^:]+' <<< "${l}")"
  var_string="$("${PYTHON}" "${THE_LIB_DIR}/pick-var.py" "${merged_vars}" "${var_name}")"
  [[ -n "${var_string}" ]] && echo "${var_string}"
done <<< "${SOURCE_CONTENT}" | (echo '---'; cat) > "${OUTPUT}"
