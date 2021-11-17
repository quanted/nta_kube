#!/bin/bash
ln -s $DB_PATH /data/db
echo "Running docker-entrypoint.sh"
sh /usr/local/bin/docker-entrypoint.sh
