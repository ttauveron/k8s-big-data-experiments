# Testing autoscaling

```shell
./bin/spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode client --master spark://192.168.99.100:30077 examples/jars/spark-examples_2.11-2.2.1.jar 10000
```
Stimulate CPU usage :

``` shell
dd if=/dev/urandom | bzip2 -9 >> /dev/null
```

# Testing Azure blob storage

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
