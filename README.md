# Spark on Kubernetes

This repo is decomposed in several proofs of concept :

<!--ts-->
   * [Proofs of concept](#proofs-of-concept)
      * [Kubernetes Operations (kops)](#kubernetes-operations-kops)
      * [Livy + Spark 2.3 using Kubernetes scheduler](#livy--spark-23-using-kubernetes-scheduler)
      * [Spark cluster deployed on Kubernetes](#spark-cluster-deployed-on-kubernetes)
      * [S3FS](#s3fs)
      * [Monitoring your cluster state with Prometheus](#monitoring-your-cluster-state-with-prometheus)
      * [Using Azure blob storage and Azure disk](#using-azure-blob-storage-and-azure-disk)
      * [Logs ingestion & analytics](#logs-ingestion--analytics)
<!--te-->

Proofs of concept
=================

Kubernetes Operations (kops)
----------------------------

This proof of concept aims at creating a Kubernetes cluster on Amazon AWS with multiple ec2 instances.

The tool used is kops and it allows to automatically setup and provision ec2 instances to form a Kubernetes cluster.

Details are available in the [kops directory](./kops)

In that directory, we have the yaml configuration of the Kubernetes cluster created by kops.

Ideally, we should create the cluster using that config, but for now, the cluster is created executing the bash script **setup-aws.sh**

You can change configuration values of that script editing environment variables defined at the top of the file.

Note that kops is using S3 to backup the cluster state.

Here are the options used to create or delete the cluster on AWS :
```shell
# Creating the cluster on AWS
./setup-aws.sh --create

# Removing the cluster on AWS (including the S3 backup storage)
./setup-aws.sh --delete
```

**Note for the following sections**

Whether you're using kops to create a cluster on AWS or, say an AKS cluster (Kubernetes as a Service on Azure), you will need to setup your AWS and Azure credentials in Kubernetes to access respectively your S3 bucket and your Azure blob storage container.

Create those credentials using the following commands before applying the following Kubernetes configurations:

``` shell
kubectl create secret generic aws \
    --from-literal=accesskey=$(aws configure get aws_access_key_id) \
    --from-literal=secretkey=$(aws configure get aws_secret_access_key)

kubectl create secret generic azure \
    --from-literal=storageaccount=STORAGE_ACCOUNT_NAME \
    --from-literal=storageaccesskey=STORAGE_ACCOUNT_ACCESS_KEY
```


Livy + Spark 2.3 using Kubernetes scheduler
-------------------------------------------

This proof of concept allows you to use Spark 2.3 Kubernetes features.

Spark 2.3 is able to submit Spark jobs (only in cluster deploy mode) to a Kubernetes cluster.

That means you cannot use it with a spark-shell, only spark-submit and you cannot upload your jar with spark-submit, so it has to be available locally or through http (yet).

It will use the Kubernetes scheduler to create Spark drivers and executors dynamically.

Refer to the [Livy/Spark README](./livy-spark-2.3/README.md) for more details.

Spark cluster deployed on Kubernetes
------------------------------------

This proof of concept is a more traditionnal approach where you deploy manually Spark to a Kubernetes cluster.

It shows how to scale the Spark number of replicas and the number of ec2 nodes in AWS.

However, there is still some work to be done to make it fully functional, especially making sure that there is only one Spark pod running on a given node.

In order to scale pods or nodes, it uses heapter metrics such as percentage of RAM/CPU used.

To apply that configuration on Kubernetes, run the following command :

```shell
kubectl apply -f spark-cluster-k8s/
```
Zeppelin notebooks are included in that repo.
[Zeppelin](https://zeppelin.apache.org/) is an interface to execute code in the Spark cluster.

Unlike the Kubernetes features on Spark 2.3, you can use spark-shell as we deploy manually our Spark workers and drivers.

#### Testing autoscaling

```shell
./bin/spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode client --master spark://192.168.99.100:30077 examples/jars/spark-examples_2.11-2.2.1.jar 10000
```
Stimulate CPU usage in a pod :

``` shell
dd if=/dev/urandom | bzip2 -9 >> /dev/null
```

S3FS
----

This is kind of a hack to expose your Spark jobs (jars) hosted on S3 so that they can be used with Spark 2.3 using Kubernetes scheduler.

The Spark 2.3 container is responsible for downloading dependencies (this is done in its initcontainer).

However, the initcontainer doesn't seem able (yet) to download the Spark jar containing the job with s3://.

S3FS is, consequently, responsible of mounting a S3 bucket as a file system in a container and exposing its content through HTTP, internally to the Kubernetes cluster.

This allows the initcontainer to download the job through HTTP.

Monitoring your cluster state with Prometheus
---------------------------------------------

Simply follow instructions described in that repo :
https://github.com/coreos/prometheus-operator

It can be extended to add things to monitor, for example using the Prometheus blackbox exporter (querying website through http to check they're alive).

Using Azure blob storage and Azure disk
---------------------------------------

#### Setup Azure on your local machine

First, make sure you have installed Azure CLI on your machine (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest). It will make it much easier than to do it in the Azure console.

Then, enter `az login` in your terminal, it will give you a link and a code. Enter the code on the webpage to authentify your computer.

The login token will be valid until it goes for 14 days without being used. Note: the token is generated for your default subscription.

Now to use kubectl on your terminal enter `az aks get-credentials --resource-group=spark-k8s --name=<cluster-name>`

#### Testing Azure blob storage

First, create a storage account on Azure named, say, testttauveron

Ref : https://docs.microsoft.com/en-us/azure/storage/blobs/storage-how-to-use-blobs-cli

```shell

az storage container create --name mystoragecontainer \
    --account-name testttauveron

az storage container set-permission --name mystoragecontainer \
    --public-access blob \
    --account-name testttauveron

az storage blob upload --container-name mystoragecontainer \
    --name spark-examples_2.11-2.3.0.jar \
    --file spark-examples_2.11-2.3.0.jar \
    --account-name testttauveron

az storage blob list --container-name mystoragecontainer \
    --account-name testttauveron

```

However you can add an extra layer of security by create a SAS (Shared Access Signature) token.

Ref: https://docs.microsoft.com/en-us/azure/storage/common/storage-dotnet-shared-access-signature-part-1
```
az storage container set-permission  \
   --name mystoragecontainer --account-name testttauveron  --public-access off

sas_start=`date -u +'%Y-%m-%dT%H:%M:%SZ'`

sas_expiry=`date -u +'%Y-%m-%dT%H:%M:%SZ' -d '+2 minute'`

sas_token=`az storage blob generate-sas \
   --container-name mystoragecontainer \
   --name spark-examples_2.11-2.3.0.jar \
   --start $sas_start \
   --expiry $sas_expiry \
   --permissions r \
   --output tsv \
   --account-name testttauveron`

echo $sas_token
```

You can now access the blobs of your container with this token! (--sas-token $sas_token)

#### Proof of concept using Azure storage to mount a volume

In [this directory](./azure-storageclass), we are setuping a Gitlab platform which uses Azure storage to backup/mount the data folder.

That means we can reuse the data volumes on Azure, for backup or migration purpose.

We are also using a Kubernetes storage class. This is used to dynamically provision a volume in Kubernetes with a given cloud provider storage service.

#### Logs ingestion & analytics

You can install the EFK (ElasticSearch, Fluentd, Kibana) stack on your kubernetes cluster.
Fluentd will be responsible for ingesting logs from all pods in all namespaces and store them in elasticsearch.
Kibana will be connected to elastucsearch to allow analytics on those logs (searching logs, graphs ...)

This stack is available here :
https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/fluentd-elasticsearch

To setup alterting, ElastAlert can be used chart helm available : [stable/elastalert](https://github.com/kubernetes/charts/tree/master/stable/elastalert).

Rule types : https://elastalert.readthedocs.io/en/latest/ruletypes.html#rule-types
