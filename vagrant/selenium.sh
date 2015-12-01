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
PIDFILE="${LOGFILE}.pid"

if [ ! -f ${DESTINATION} ]; then
  curl -O ${DOWNLOAD_URL}

  if [ $? -gt 0 ]; then
    echo "Cannot download file: ${DOWNLOAD_URL}"
    exit 1
  fi

  mv ${DOWNLOAD_URL##*/} ${DESTINATION}
fi

if [ -f ${PIDFILE} ]; then
  PID=$(cat ${PIDFILE})

  if [ -n ${PID} ]; then
    kill ${PID}
  fi
fi

nohup java -jar ${DESTINATION} -role node > ${LOGFILE}.out.log 2> ${LOGFILE}.error.log < /dev/null &
echo $! > ${PIDFILE}
