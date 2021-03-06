#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export PYTHONPATH=$SCRIPT_DIR

# Set the ini file path 
export OASIS_API_INI_PATH="${SCRIPT_DIR}/conf.ini"

# Delete celeryd.pid file - fix que pickup issues on reboot of server
rm -f /home/worker/celeryd.pid

./src/utils/wait-for-it.sh "oasis_rabbit:$RABBIT_PORT"
./src/utils/wait-for-it.sh "oasis_mysql:$MYSQL_PORT"

# Start worker on init
celery worker -A src.model_execution_worker.tasks --detach --loglevel=INFO --logfile="/var/log/oasis/worker.log" -Q "${MODEL_SUPPLIER_ID}-${MODEL_VERSION_ID}"

sleep 5

tail -f /var/log/oasis/worker.log
