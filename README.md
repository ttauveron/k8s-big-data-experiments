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

# Livy REST API Testing

You can use Postman (https://www.getpostman.com/) and import the postman collection in the repo to test Livy REST API.

#### Create a session
```shell
curl -X POST \
  http://192.168.99.100:30998/sessions \
  -H 'content-type: application/json' \
  -d '{
	"kind": "spark"
}'
```

#### List sesssions
```shell
curl -X GET http://192.168.99.100:30998/sessions
```
#### Get session (id=0)

```shell
curl -X GET http://192.168.99.100:30998/sessions/0
```

#### Create a statement in a session (= send scala to Spark)

```shell
curl -X POST \
  http://192.168.99.100:30998/sessions/0/statements \
  -H 'content-type: application/json' \
  -d '{"code": "val NUM_SAMPLES = 100000;\nval count = sc.parallelize(1 to NUM_SAMPLES).map { i =>\nval x = Math.random();\nval y = Math.random();\nif (x*x + y*y < 1) 1 else 0\n}.reduce(_ + _);\nprintln(\"Pi is roughly \" + 4.0 * count / NUM_SAMPLES)"}'
```

#### List statements of a session

```shell
curl -X GET http://192.168.99.100:30998/sessions/0/statements
```

#### Get result of a statement

```shell
curl -X GET http://192.168.99.100:30998/sessions/0/statements/0
```
