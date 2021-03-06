#!/bin/bash

CLI="/usr/bin/duplicati-commandline"
BUCKET=${BUCKET}
COMMAND=$1

AUTH="--aws_access_key_id=${BACKUP_S3_KEY} --aws_secret_access_key=${BACKUP_S3_SECRET}"
SERVER="s3://$(echo ${BACKUP_S3_KEY}-${BUCKET} | tr '[:upper:]' '[:lower:]')/"
MONO_EXTERNAL_ENCODINGS="UTF-8"

function test_var () {
    if [ -z "$1" ]; then
        echo "Variable is not set."
        exit 1
    fi
}

function rotate ()  {
    test_var ${DELETE_ALL_BUT_N_FULL}
    ${CLI} delete-all-but-n-full ${DELETE_ALL_BUT_N_FULL} ${AUTH} --use-ssl  --force ${SERVER}
}

function backup ()  {
    if [ ! -f /data/.restored ]; then
        echo "There is no recovery information."
        exit 1
    fi
    ${CLI} backup --tempdir=/tmp ${AUTH} --volsize=20mb --full-if-older-than=1M --accept-any-ssl-certificate --no-encryption --use-ssl /data ${SERVER}
}

function restore () {
    ${CLI} restore --tempdir=/tmp ${AUTH} --accept-any-ssl-certificate --no-encryption --use-ssl ${SERVER} /data
	if [ $? -eq 0 ] || [ $? -eq 1 ] || [ $? -eq 2 ]; then
		echo $(date) > /data/.restored
	else
		echo "Restore fail."
		exit 1
	fi
}

test_var ${BUCKET}
test_var ${BACKUP_S3_KEY}
test_var ${BACKUP_S3_SECRET}

if   [ "${COMMAND}" == 'rotate' ]; then
    echo "START - rotate."
    rotate
elif [ "${COMMAND}" == 'backup' ]; then
    echo "START - backup."
    backup
elif [ "${COMMAND}" == 'restore' ]; then
    echo "START - restore."
    restore
else
    echo "Command - ${COMMAND} is not supported."
    exit 1
fi