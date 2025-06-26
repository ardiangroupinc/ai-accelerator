# ArdianGroup AI Accelerator

Welcome to the AI Accelerator project source code. This project was inspired by [Red Hat's AI Accelerator project](https://github.com/redhat-ai-services/ai-accelerator), which is designed to initialize an OpenShift cluster with a recommended set of operators and components that aid with training, deploying, serving and monitoring Machine Learning models in a GitOps fashion using Argo. Once all the configuration is in Git, reinstalling it on a cluster in case it ever goes away is quick and semi-automatic.

You can learn more about the project setup and/or howtos by clicking on the guide links below. If your curious about the original ai-accelerator project click on the link above. 

![AI Accelerator Overview](documentation/diagrams/AI_Accelerator.drawio.png)

## Additional Documentation and Info
* [Overview](documentation/overview.md) - what's inside this repository?

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


## How Tos
* [Installation Guide](documentation/installation.md) - containing step by step instructions for executing this installation sequence on your cluster in order to install RHOAI and related operators on it.