#!/bin/bash

TS=`date +"%Y%m%d-%H%M%S"`
BACKUPS_PATH="{{ pg_dump.path }}"
FILENAME="$TS.dump"
DUMP_PATH="$BACKUPS_PATH$FILENAME"
DBNAME="{{ pg_dump.dbname }}"

echo "Dumping '$DBNAME' to '$DUMP_PATH' in PG custom format."
pg_dump -Fc $DBNAME > "$DUMP_PATH" && echo "Done!"

# restore with: "pg_restore -d __dbname__ __path_to_dump__"
