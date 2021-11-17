#!/bin/bash
mkdir $DB_PATH
ln -s $DB_PATH /data/db
sh /usr/local/bin/docker-entrypoint.sh
