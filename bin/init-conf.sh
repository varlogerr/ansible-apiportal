#!/usr/bin/env bash

THE_SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
THE_SCRIPT_DIR="$(cd "$(dirname "${THE_SCRIPT_PATH}")" &> /dev/null && pwd)"
THE_PROJECT_DIR="$(realpath "${THE_SCRIPT_DIR}/..")"
THE_SAMPLES_DIR="$(realpath "${THE_PROJECT_DIR}/samples")"
THE_CONF_DIR="$(realpath "${THE_PROJECT_DIR}/conf")"

print_help() {
  while read -r l; do
    [[ -n "${l}" ]] && echo "${l}"
  done <<< "
    Initialize configuration skeleton and optionally copy
    apiportal installer with the right name to be autodetected.
  "
  echo
  echo "Available options:"

  while read -r l; do
    [[ -n "${l}" ]] && echo "  ${l}"
  done <<< "
    -h, -?, --help  Print this help.
  "

  echo "Demo usage:"
  while read -r l; do
    [[ -n "${l}" ]] && echo "  ${l}"
  done <<< "
    # Just initialize configuration directory
    $(basename "${THE_SCRIPT_PATH}")
    # Iinitialize configuration directory and copy
    # apiportal installer to it
    $(basename "${THE_SCRIPT_PATH}") ~/Downloads/apiportal.tgz
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
    -*)
      INVALID+=("${1}")
      ;;
    *)
      INSTALLER="${1}"
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

if [[ ! -d "${THE_CONF_DIR}" ]]; then
  for d in host_vars group_vars secrets; do
    mkdir -p "${THE_CONF_DIR}/${d}"
    touch "${THE_CONF_DIR}/${d}/.gitignore"
  done

  cp "${THE_SAMPLES_DIR}/inv.yml" "${THE_CONF_DIR}"
fi

if [[ -n "${INSTALLER}" ]] && [[ -f "${INSTALLER}" ]]; then
  dest_file="$(basename "${INSTALLER}")"

  if [[ "${dest_file}" != apiportal-*install*.tgz ]]; then
    dest_file=apiportal-install-package.tgz
  fi

  cp ${INSTALLER} "${THE_CONF_DIR}/${dest_file}"
fi
