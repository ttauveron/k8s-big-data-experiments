# Spark on Kubernetes

Download spark-2.2.1-bin-hadoop2.7.tgz and put the tgz in the current directory
https://spark.apache.org/downloads.html

```shell
eval $(minikube docker-env)
docker build -t myspark .
kubectl create secret generic aws --from-literal=access-key=YOUR_ACCESS_KEY --from-literal=secret-key=YOUR_SECRET_KEY
kubectl create -f spark-k8s
```
