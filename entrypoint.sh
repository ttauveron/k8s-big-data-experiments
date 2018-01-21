#!/bin/sh

set -e

echo "bonjour!" >> bonjour.txt

if [ "$MYSQL_DATABASE" ]; then
    echo $MYSQL_DATABASE >> /test.txt
fi

exec "$@"
