#!/bin/bash

export DOMAIN_NAME="k8s.local"
export CLUSTER_ALIAS="thibaut"

export CLUSTER_FULL_NAME="${CLUSTER_ALIAS}.${DOMAIN_NAME}"
export CLUSTER_AWS_REGION="us-east-1"
export CLUSTER_AWS_AZ="us-east-1a"

export KOPS_STATE_STORE="s3://${CLUSTER_FULL_NAME}-state"
export MAX_NODES="4"



PROGNAME=$0
usage() {
    cat << EOF >&2
Usage: $PROGNAME [--create] [--delete]
EOF
    exit 1
}


create() {

    aws s3api create-bucket --bucket ${CLUSTER_FULL_NAME}-state

    export KOPS_STATE_STORE="s3://${CLUSTER_FULL_NAME}-state"

    #--master-size="t2.medium" \
    #--node-size="t2.micro" \
    #--node-count="2" \
    kops create cluster \
         --name=${CLUSTER_FULL_NAME} \
         --zones=${CLUSTER_AWS_AZ} \
         --dns-zone=${DOMAIN_NAME} \
         --ssh-public-key="~/.ssh/id_rsa.pub" \
         --kubernetes-version="1.8.7" --yes


    kubectl config use-context ${CLUSTER_FULL_NAME}
    echo -n "Waiting for cluster components to become ready."
    until [ $(kubectl get cs 2> /dev/null| grep -e Healthy | wc -l | xargs) -ge 4 ]
    do
        echo -n "."
        sleep 1
    done
    echo "ok"

    echo -n "Waiting for minimum nodes to become ready."
    min_nodes=$(kops get ig nodes --name ${CLUSTER_FULL_NAME} | grep nodes | awk '{print $4}')
    until [ "$(kubectl get nodes 2> /dev/null| grep -v master | grep -e Ready | wc -l | xargs)" == "$min_nodes" ]
    do
        echo -n "."
        sleep 1
    done
    echo "ok"

    # Add heapster
    kubectl apply --filename https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/rbac/heapster-rbac.yaml
    kubectl apply --filename https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/standalone/heapster-controller.yaml

    # Set maximum number of nodes
    kops get ig nodes -oyaml > nodes.yaml
    sed -i -e "s|maxSize:.*|maxSize: ${MAX_NODES}|g" nodes.yaml
    kops replace -f nodes.yaml
    rm nodes.yaml
    kops update cluster ${CLUSTER_FULL_NAME} --yes

    while true; do
        kops validate cluster ${CLUSTER_FULL_NAME} --state ${KOPS_STATE_STORE} && break || sleep 5
        echo -n "."
    done;

    # Autoscaling
    aws iam put-role-policy --role-name nodes.${CLUSTER_FULL_NAME} \
        --policy-name asg-nodes.${CLUSTER_FULL_NAME} \
        --policy-document file://kops/policy-cluster-autoscaler.json

    export MIN_NODES="2"

    sed -i -e "s|--nodes=.*|--nodes=${MIN_NODES}:${MAX_NODES}:nodes.${CLUSTER_FULL_NAME}|g" spark-k8s/cluster-autoscaler-deploy.yaml
    sed -i -e "s|value: .*|value: ${CLUSTER_AWS_REGION}|g" spark-k8s/cluster-autoscaler-deploy.yaml

    #kubectl apply -f spark-k8s/cluster-autoscaler-deploy.yaml

    # Creating spark cluster
#    kubectl create secret generic aws \
#            --from-literal=accesskey=$(aws configure get aws_access_key_id) \
#            --from-literal=secretkey=$(aws configure get aws_secret_access_key)
#    kubectl create -f spark-k8s/

    echo "Kubernetes cluster creation on Amazon ec2 successful"

}

delete() {
    kops delete cluster ${CLUSTER_FULL_NAME} --yes
    aws s3api delete-bucket --bucket ${CLUSTER_FULL_NAME}-state
}



parse_args() {


    case "$1" in
        --delete)
            delete
            ;;
        --create)
            create
            ;;
        *)
            usage
            ;;
    esac
}

if [[ "$#" == 1 ]]; then
    parse_args "$1"
    shift
else
    usage
fi

exit 1
