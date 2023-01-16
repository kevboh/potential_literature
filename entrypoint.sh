#!/bin/bash

if [ ! -f /mnt/db/pl.db ]; then
    echo "Creating database file"
    sqlite3 /mnt/db/pl.db
fi

/app/entry eval PotentialLiterature.Release.migrate && \
    /app/entry start
