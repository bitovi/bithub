#!/usr/bin/env bash

export PRODUCTION_PRIVATE_IP=192.168.143.36

pg_dump --host=${PRODUCTION_PRIVATE_IP} --format=c bithub > /pg_dumps/deploy.dump
pg_restore --dbname=bithub --clean --if-exists --format=custom /pg_dumps/deploy.dump

