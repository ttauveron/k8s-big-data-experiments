# Spark on Kubernetes

_Note : This following step is not required anymore as the Spark docker image is available on dockerhub and pulled automatically_

Download spark-2.2.1-bin-hadoop2.7.tgz and put the tgz in the current directory

https://spark.apache.org/downloads.html

```shell
eval $(minikube docker-env)
pushd docker/spark
docker build -t myspark .
popd

```

Then, launch the Spark cluster creation

``` shell
kubectl create secret generic aws \
    --from-literal=accesskey=$(aws configure get aws_access_key_id) \
    --from-literal=secretkey=$(aws configure get aws_secret_access_key)
kubectl create -f spark-k8s
```

# Use Kubernetes scheduler with Spark's Kubernetes capabilities

First, download the 2.3 version of the spark repo

``` shell
wget https://github.com/apache/spark/archive/v2.3.0-rc4.tar.gz
tar xzf v2.3.0-rc4.tar.gz
cd spark-2.3.0-rc4/

# Building Spark
./dev/make-distribution.sh --name custom-spark --tgz -Phadoop-2.7 -Phive -Phive-thriftserver -Pmesos -Pyarn -Pkubernetes

```

Before building the docker container, add the following lines to **resource-managers/kubernetes/docker/src/main/dockerfiles/spark/Dockerfile**

```Dockerfile
RUN mkdir -p /opt/spark/extras && \
    wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar -P /opt/spark/extras && \
    wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar -P /opt/spark/extras
```


``` shell
# Build docker spark image and push it to dockerhub
bin/docker-image-tool.sh -r gnut3ll4 -t v1.0.2 build
bin/docker-image-tool.sh -r gnut3ll4 -t v1.0.2 push

kubectl proxy --address 0.0.0.0 --port=8443 --accept-hosts ".*"&

# Submit a job to the kubernetes cluster
bin/spark-submit --master k8s://http://127.0.0.1:8443 --deploy-mode cluster --name spark-pi --class org.apache.spark.examples.SparkPi --conf spark.executor.instances=5 --conf spark.kubernetes.container.image=gnut3ll4/spark:v1.0.2 local:///opt/spark/examples/target/original-spark-examples_2.11-2.3.0.jar
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

# Zeppelin Notebooks

[Zeppelin](https://zeppelin.apache.org/) is an interface to execute code in the Spark cluster. You can access it at [http://192.168.99.100:30111](http://192.168.99.100:30111).
