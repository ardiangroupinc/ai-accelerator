# ArdianGroup AI Accelerator

Welcome to the AI Accelerator project source code. This project was inspired by [Red Hat's AI Accelerator project](https://github.com/redhat-ai-services/ai-accelerator), which is designed to initialize an OpenShift cluster with a recommended set of operators and components that aid with training, deploying, serving and monitoring Machine Learning models in a GitOps fashion using Argo and kustomize. Once all the configuration is in Git, reinstalling it on a cluster in case the cluster ever goes away is quick and semi-automatic.

You can learn more about the project setup and/or howtos by clicking on the guide links below. If your curious about the original ai-accelerator project click on the link above. 

## How Tos
* [Installation Guide](documentation/installation.md) - containing step by step instructions for executing this `bootstrap.sh` installation sequence on your cluster in order to install RHOAI and related operators on it.
* [ArgoCD Howtos](documentation/configuring-argo.md#argocd-howtos) - What argo settings should we be aware of and how do we change them?

## Additional Documentation and Info
* [Overview](documentation/overview.md) - What's inside this repository?
* [ArgoCD Setup](documentation/configuring-argo.md) - What argo settings should we be aware of and how do we change them?

### Operators

* [Authorino Operator](components/operators/authorino-operator/)
* [NVIDIA GPU Operator](components/operators/gpu-operator-certified/)
* [Node Feature Discovery Operator](components/operators/nfd/)
* [OpenShift AI](components/operators/openshift-ai/)
* [OpenShift Pipelines](components/operators/openshift-pipelines/)
* [OpenShift Serverless](components/operators/openshift-serverless/)
* [OpenShift ServiceMesh](components/operators/openshift-servicemesh/)

### Applications

* OpenShift GitOps: [ArgoCD](components/argocd/)
* S3 compatible storage: [MinIO](components/apps/minio)

### Configuration

* [Bootstrap Overlays](bootstrap/overlays/)
* [Cluster Configuration Sets](clusters/overlays/)

### Tenants

* [Tenant Examples](tenants/)


