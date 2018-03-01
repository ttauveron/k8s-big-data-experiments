# Testing autoscaling

```shell
./bin/spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode client --master spark://192.168.99.100:30077 examples/jars/spark-examples_2.11-2.2.1.jar 10000
```
Stimulate CPU usage :

``` shell
dd if=/dev/urandom | bzip2 -9 >> /dev/null
```
# Setup Azure on your local machine

First, make sure you have installed Azure CLI on your machine (https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest). It will make it much easier than to do it in the Azure console. 
Then, enter `az login` in your terminal, it will give you a link and a code. Enter the code on the webpage to authentify your computer. The login token will be valid until it goes for 14 days without being used. Note: the token is generated for your default subscription.

Now to use kubectl on your terminal enter `az aks get-credentials --resource-group=spark-k8s --name=<cluster-name>`

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
