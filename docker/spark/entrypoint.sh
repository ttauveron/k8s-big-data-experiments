#!/bin/bash

set -e


if [ "$AWS_ACCESS_KEY" ] && [ "$AWS_SECRET_KEY" ]
then
    sed -i -e "s~\${aws_access_key}~$AWS_ACCESS_KEY~" \
        -e "s~\${aws_secret_key}~$AWS_SECRET_KEY~" \
        /opt/spark/conf/spark-defaults.conf
fi

exec "$@"
