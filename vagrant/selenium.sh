#!/usr/bin/env bash

DOWNLOAD_URL="$1"
FILENAME="selenium.jar"
ROOT=".vagrant"

if [[ -z ${DOWNLOAD_URL} || ! -d ${ROOT} ]]; then
  exit
fi

DESTINATION="${ROOT}/${FILENAME}"
LOGFILE="${ROOT}/${FILENAME%%.*}"

if [ ! -f ${DESTINATION} ]; then
  curl -O ${DOWNLOAD_URL}
  mv ${DOWNLOAD_URL##*/} ${DESTINATION}
fi

PID=$(ps aux | grep ${FILENAME} | grep -v grep | awk '{print $2}')

if [ -n "${PID}" ]; then
  kill ${PID}
fi

nohup java -jar ${DESTINATION} -role node > ${LOGFILE}.out.log 2> ${LOGFILE}.error.log < /dev/null &
