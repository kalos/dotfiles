#!/usr/bin/env bash

# notify in case of error
set -eE  # same as: `set -o errexit -o errtrace`
trap '_error_trap $? $LINENO' ERR

_error_trap(){
  if [ "$1" != "0" ]; then
    echo >&2 "Error - exited with status $1 at line $2:" ; pr -tn $0 | tail -n+$((${2} - 3)) | head -n7
    /home/kalos/.bin/notify.sh -u critical "resticprofile check last backup: exited ($1) at line $2"
  fi
}


# default value
STATUS_FILE="${HOME}/.config/resticprofile/.resticprofile.status"

THRESHOLD='7 days'
CRITICAL_THRESHOLD='14 days'

# use arguments if exists
[[ -n $1 ]] && THRESHOLD="${1}"
[[ -n $2 ]] && CRITICAL_THRESHOLD="${2}"

date_threshold=$(date -d "now - ${THRESHOLD}" +'%s')
date_critical_threshold=$(date -d "now - ${CRITICAL_THRESHOLD}" +'%s')


for profile in $(cat "${STATUS_FILE}" | jq -r '.[] | keys | .[]'); do
  last_backup_string="$(cat ${STATUS_FILE} | jq -r .[].${profile}.backup.time)"
  last_backup="$(date -d "${last_backup_string}" +%s)"

  # check if the last backup is older than THRESHOLD
  if [[ "${date_threshold}" -gt "${last_backup}" ]] || [[ -z "${last_backup}" ]] ; then

    # convert date in "human format"
    last_backup_date=$(date -d "${last_backup_string}" +'%d/%m/%Y %R')

    # if the last backup is older than CRITICAL_THRESHOLD, send critical alarm
    if [[ "${date_critical_threshold}" -gt "${last_backup}" ]] ; then
      /home/kalos/.bin/notify.sh -u critical "restic: $profile backup is TOO old!" "last backup: ${last_backup_date}"
    else
      /home/kalos/.bin/notify.sh "restic: $profile backup is a bit old!" "last backup: ${last_backup_date}"
    fi
  fi
done
