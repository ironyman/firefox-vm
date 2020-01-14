#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. $DIR/config.sh

if [[ $EUID -ne 0 ]]; then
    exec sudo /bin/bash $0 $@
fi

pid=$(<$PID_FILE)

TRIES=10

while [[ $TRIES -gt 0 ]]; do
    if kill $pid 2>/dev/null; then
        echo It exited.
        break
    fi
    TRIES=$((TRIES - 1))
    echo kill returned $?. $TRIES tries left
    sleep 10
done

if [[ $TRIES -eq 0 ]]; then
    kill -9 $pid
fi

rm $PID_FILE
