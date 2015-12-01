#!/usr/bin/env bash

DOWNLOAD_URL="$1"
FILENAME="selenium.jar"
ROOT=".vagrant"

if [[ -z ${DOWNLOAD_URL} || ! -d ${ROOT} ]]; then
  echo "Download URL or ${ROOT} directory does not exists."
  exit 1
fi

DESTINATION="${ROOT}/${FILENAME}"
LOGFILE="${ROOT}/${FILENAME%%.*}"

if [ ! -f ${DESTINATION} ]; then
  curl -O ${DOWNLOAD_URL}

  if [ $? -gt 0 ]; then
    echo "Cannot download file: ${DOWNLOAD_URL}"
    exit 1
  fi

  mv ${DOWNLOAD_URL##*/} ${DESTINATION}
fi

PID=$(ps aux | grep ${FILENAME} | grep -v grep | awk '{print $2}')

if [ -n "${PID}" ]; then
  kill ${PID}
fi

nohup java -jar ${DESTINATION} -role node > ${LOGFILE}.out.log 2> ${LOGFILE}.error.log < /dev/null &
