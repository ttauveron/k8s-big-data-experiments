# Setup Prometheus

Follow instructions in that repo :
https://github.com/coreos/prometheus-operator/tree/master/contrib/kube-prometheus

# Azure file
Note : It doesn't work with gitlab as a volume because gitlab wants to change permissions and it's apparently not possible with storage account. 

## Setup storage class

Create a storage account on Azure named, say, testttauveron
Ref : https://docs.microsoft.com/en-us/azure/storage/blobs/storage-how-to-use-blobs-cli

It must use the same resource-group than AKS-agentpool in Azure

## Reusing Azure volume

To reuse the volume storageclass has created, for example, if we have deleted the pvc, we have to delete first the pv with kubectl.
The volume is still available in Storage account on Azure.
Then we want to reuse that volume.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: azure-secret
type: Opaque
data:
  azurestorageaccountname: [base64encoded storageaccountname]
  azurestorageaccountkey: [base64encoded storageaccountkey]
```

Note : On azure, Storage account > Access key > Choose a Key
The key seems already encoded, but you still have to encode it in base64 

Then in the gitlab pod : 

```yaml
      volumes:
        - name: "data"
#          persistentVolumeClaim:
#            claimName: mypvc
          azureFile:
            secretName: azure-storage-account-testttauveron-secret
            shareName: kubernetes-dynamic-pvc-xxxxxxxx
            readOnly: false
```

- secretName should be created by storageclass 
```shell
kubectl get secret [secretname] -o yaml
```


