#!/bin/bash

set -e


if [ "$K8S_API_HOST" ]
then
   sed -i -e "s~\${k8s_api_host}~$K8S_API_HOST~" \
        /opt/livy/conf/livy.conf
fi

exec "$@"
