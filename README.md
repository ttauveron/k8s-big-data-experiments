# Spark on Kubernetes

Download spark-2.2.1-bin-hadoop2.7.tgz and put the tgz in the current directory
https://spark.apache.org/downloads.html

```shell
eval $(minikube docker-env)
pushd docker/spark
docker build -t myspark .
kubectl create secret generic aws --from-literal=accesskey=YOUR_ACCESS_KEY --from-literal=secretkey=YOUR_SECRET_KEY
popd
kubectl create -f spark-k8s
```
