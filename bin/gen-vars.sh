#!/usr/bin/env bash

THE_SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
THE_SCRIPT_DIR="$(cd "$(dirname "${THE_SCRIPT_PATH}")" &> /dev/null && pwd)"
THE_SAMPLES_DIR="$(realpath "${THE_SCRIPT_DIR}/../samples")"

print_help() {
  while read -r l; do
    [[ -n "${l}" ]] && echo "${l}"
  done <<< "
    Generage vars file. If you generate it into an existing vars file,
    the values will not be changed to default ones.
  "
  echo
  echo "Available options:"

  while read -r l; do
    [[ -n "${l}" ]] && echo "  ${l}"
  done <<< "
    -o, --output    Output target file. Required.
    -h, -?, --help  Print this help.
  "

  echo "Demo usage:"
  echo "  $(basename "${THE_SCRIPT_PATH}") -o ./host_vars/apiportal.yml"
}

# collect options
while :; do
  case "${1}" in
    -h|-\?|--help)
      print_help
      exit
      ;;

    --output=?*)
      TARGET="${1#*=}"
      ;;
    --output|-o)
      TARGET="${2}"
      shift
      ;;
    *)
      break
      ;;
  esac

  shift
done

if [[ -z "${TARGET}" ]]; then
  echo "Output target is required!"
  echo
  print_help
  exit 1
fi

TARGET_DIR="$(dirname "${TARGET}")"

if [[ ! -d "${TARGET_DIR}" ]]; then
  mkdir "${TARGET_DIR}"
fi

if [[ ! -f "${TARGET}" ]]; then
  touch "${TARGET}"
fi

TARGET="$(realpath "${TARGET}")"

sample_content="$(cat "${THE_SAMPLES_DIR}/vars.yml")"
target_content="$(cat "${TARGET}")"
target_vars="$(grep -P '^[^\#|^\s|^\-].*' <<< "${target_content}")"

# compare source content with target content
# and output to the target file
while IFS= read -r l; do
  # doesn't start with '#', '-' or space
  # grab everything up to first ':'
  var_name="$(
    grep -P '^[^\#|^\s|^\-].*' <<< "${l}" \
    | grep -Po '^[^:]+'
  )"

  if [[ -z "${var_name}" ]]; then
    # it's not a var, print out directly
    echo "${l}"
    continue;
  fi

  var_found="$(grep -- "^${var_name}:" <<< "${target_vars}")"
  if [[ -n "${var_found}" ]]; then
    echo "${var_found}"
    continue
  fi

  echo "${l}"
done <<< "${sample_content}" > "${TARGET}"
