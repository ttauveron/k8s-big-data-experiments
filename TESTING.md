# Testing autoscaling

```shell
./bin/spark-submit --class org.apache.spark.examples.SparkPi --deploy-mode client --master spark://192.168.99.100:30077 examples/jars/spark-examples_2.11-2.2.1.jar 10000
```
Stimulate CPU usage :

``` shell
dd if=/dev/urandom | bzip2 -9 >> /dev/null
```
