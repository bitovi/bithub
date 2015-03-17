#!/bin/bash

TS=`date +"%Y%m%d-%H%M%S"`
BACKUPS_PATH="/dbbackups/"
FILENAME="$TS.backup"
DUMP_PATH="$BACKUPS_PATH$FILENAME"
DBNAME="bithub"

echo "Dumping '$DBNAME' to '$DUMP_PATH' in PG custom format."
pg_dump -Fc $DBNAME > "$DUMP_PATH" && echo "Done!"

# restore with: "pg_restore -d __dbname__ __path_to_dump__"
