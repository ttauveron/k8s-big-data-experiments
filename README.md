# Spark on Kubernetes

This repo is decomposed in several proofs of concept :

<!--ts-->
   * [Proofs of concept](#proofs-of-concept)
      * [Kubernetes Operations (kops)](#kubernetes-operations-kops)
      * [Livy + Spark 2.3 using Kubernetes scheduler](#livy--spark-23-using-kubernetes-scheduler)
      * [Spark cluster deployed on Kubernetes](#spark-cluster-deployed-on-kubernetes)
      * [S3FS](#s3fs)
<!--te-->

Proofs of concept
=================

Kubernetes Operations (kops)
----------------------------

This proof of concept aims at creating a Kubernetes cluster on Amazon AWS with multiple ec2 instances.
The tool used is kops and it allows to automatically setup and provision ec2 instances to form a Kubernetes cluster.


Livy + Spark 2.3 using Kubernetes scheduler
-------------------------------------------

This proof of concept allows you to use Spark 2.3 Kubernetes features.
Spark 2.3 is able to submit Spark jobs (only in cluster deploy mode) to a Kubernetes cluster.
It will use the Kubernetes scheduler to create Spark drivers and executors dynamically.

Spark cluster deployed on Kubernetes
------------------------------------

This proof of concept is a more traditionnal approach where you deploy manually Spark to a Kubernetes cluster.
It shows how to scale the Spark number of replicas and the number of ec2 nodes in AWS.
However, there is still some work to be done to make it fully functional, especially making sure that there is only one Spark pod running on a given node.
In order to scale pods or nodes, it uses heapter metrics such as percentage of RAM/CPU used.

S3FS
----

This is kind of a hack to expose your Spark jobs (jars) hosted on S3 so that they can be used with Spark 2.3 using Kubernetes scheduler.
The Spark 2.3 container is responsible for downloading dependencies (this is done in its initcontainer). 
However, the initcontainer doesn't seem able (yet) to download the Spark jar container the job with s3://.
S3FS is, consequently, responsible of mounting a S3 bucket as a file system in a container and exposing its content through HTTP, internally to the Kubernetes cluster. 
This allows the initcontainer to download the job through HTTP.





--TODO



Then, launch the Spark cluster creation

``` shell
kubectl create secret generic aws \
    --from-literal=accesskey=$(aws configure get aws_access_key_id) \
    --from-literal=secretkey=$(aws configure get aws_secret_access_key)
    
kubectl create secret generic azure \
    --from-literal=storageaccount=STORAGE_ACCOUNT_NAME \
    --from-literal=storageaccesskey=STORAGE_ACCOUNT_ACCESS_KEY

kubectl create -f spark-k8s
```

# Use Kubernetes scheduler with Spark's Kubernetes capabilities

First, download Spark 2.3

``` shell
wget -P /opt https://www.apache.org/dist/spark/spark-2.3.0/spark-2.3.0-bin-hadoop2.7.tgz
cd /opt
tar xvzf spark-2.3.0-bin-hadoop2.7.tgz
rm spark-2.3.0-bin-hadoop2.7.tgz
cd spark-2.3.0-bin-hadoop2.7
```

Before building the docker container, add the following lines to **/opt/spark-2.3.0-bin-hadoop2.7/kubernetes/dockerfiles/spark/Dockerfile**

```Dockerfile
RUN wget -P ${SPARK_HOME}/jars http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar && \
    wget -P ${SPARK_HOME}/jars http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.3/hadoop-aws-2.7.3.jar && \
    wget -P ${SPARK_HOME}/jars http://central.maven.org/maven2/com/microsoft/azure/azure-storage/7.0.0/azure-storage-7.0.0.jar && \
    wget -P ${SPARK_HOME}/jars http://central.maven.org/maven2/org/apache/hadoop/hadoop-azure/2.7.5/hadoop-azure-2.7.5.jar

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
