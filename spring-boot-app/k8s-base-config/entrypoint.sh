#!/bin/bash

set -e

if [ "$DB_URL" ] && [ "$DB_USERNAME" ] && [ "$DB_PASSWORD" ]
then
    sed -i -e "s~\${db_url}~$DB_URL~" \
        -e "s~\${db_username}~$DB_USERNAME~" \
        -e "s~\${db_password}~$DB_PASSWORD~" \
        /config/userdb.properties
fi

exec "$@"