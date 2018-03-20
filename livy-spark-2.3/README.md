# Using Livy for Spark on Kubernetes
## Getting started
This package aims at using livy on top of spark 2.3 (using the kubernetes scheduler).

The livy Dockerfile adds a spark-2.3.0-bin-custom-spark.tgz to the Docker container.
I didn't include this file in the repo (200MB) but it is produced from the spark 2.3 build, so add it in the folder before running a docker build.

(For how to build Spark 2.3, see https://github.com/ttauveron/spark_k8s#use-kubernetes-scheduler-with-sparks-kubernetes-capabilities)

The livy-deployment (running on Kubernetes) uses a sidecar container in its pod in order to provide a kubectl proxy. Actually, Spark will be using Kubernetes API to create Spark driver and executors pods.

Finally, if you want to run the livy container locally, you can use Docker without kubernetes with the following commands :

```shell
# Creating the proxy for the Kubernetes cluster
kubectl proxy --address 0.0.0.0 --port=8443 --accept-hosts ".*"

# Replace K8S_API_HOST by your local IP (has to be accessible from a container)
docker run --rm --name livy -d -p 8998:8998 -e K8S_API_HOST=thibaut.dev.ticksmith.com livy
```

I uploaded some images on my dockerhub account, so the solution can be deployed just using :

``` shell
kubectl apply -f livy-deployment.yaml
```

Then, you may want to add a s3fs pod. 
This pod aims at mounting a s3 bucket and serving it internally by http (in kubernetes cluster).
It allows to access spark programs executables from s3 through http without making them public.

```shell
kubectl apply -f ../s3fs/s3fs-kubernetes.yaml
```

## Postman Collection

You can use the Postman collection available at the root of the repo.
Only 2.X request will be working because Spark 2.3 using Kubernetes doesn't support interactive shell.
Also, it's not possible yet to upload a jar so your jar has to be available from a URL (or locally).

In the Postman Collection, you can configure a collection variable to define yhe Livy IP for all requests. Details available in here : https://www.getpostman.com/docs/v6/postman/environments_and_globals/variables#defining-collection-variables
