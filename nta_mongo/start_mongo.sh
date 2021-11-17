#!/bin/bash
ln -s $DB_PATH /data/db
echo "Running docker-entrypoint.sh"
bash /usr/local/bin/docker-entrypoint.sh
