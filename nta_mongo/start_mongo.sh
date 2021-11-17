#!/bin/bash
ln -s $DB_PATH /data/db
echo "Running docker-entrypoint.sh"
/bin/sh -c /usr/local/bin/docker-entrypoint.sh
