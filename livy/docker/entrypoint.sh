#!/bin/bash

set -e


if [ "$K8S_API_HOST" ]
then
   sed -i -e "s~\${k8s_api_host}~$K8S_API_HOST~" \
        /opt/livy/conf/livy.conf
fi

if [ "$AWS_ACCESS_KEY" ] && [ "$AWS_SECRET_KEY" ]
then
   sed -i -e "s~\${aws_access_key}~$AWS_ACCESS_KEY~" \
       -e "s~\${aws_secret_key}~$AWS_SECRET_KEY~" \
       /opt/spark/conf/spark-defaults.conf
fi

if [ "$SPARK_KUBERNETES_IMAGE" ]
then
   sed -i -e "s~\${spark_kubernetes_image}~$SPARK_KUBERNETES_IMAGE~" \
       /opt/spark/conf/spark-defaults.conf
fi
     

exec "$@"
