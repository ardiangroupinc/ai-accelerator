# rhoai-ibmcloud-lab

To facilitate ai/ml development for ArdianGroup on ROKS and RHOAI, we carried out two points as the starting foundation:
* [ai-accelerator's rhoai-eus-2.16-aws-gpu](https://github.com/redhat-ai-services/ai-accelerator/tree/main/bootstrap/overlays/rhoai-eus-2.16-aws-gpu) was chosen as the basis to start from because it had RHOAI 2.16 and nvidia gpus kustomize configurations for fulfilling gpu use by the data scientists. It was close enough to the RHOAI instance that we manually stood up. eus stands for extended update support which seemed a no-brainer to include.
* "rhoai-ibmcloud-lab" was the name chosen for installing ArgoCD and Red Hat Openshift AI on the given ROKS cluster. Under all the folders named "overlays" you will find the directory "rhoai-ibmcloud-lab" pointing to and tweaking content given in adjacent folders called "base".

In this directory you will find the starting or bootstrap `kustomization.yaml` file to be used by `bootstrap.sh` command at the root of the ai-accelerator project. This will allow us to execute standing up of ArgoCD and RHOAI on the ROKS cluster by a team member executing the `bootstrap.sh` command.

ROKS is supposed to be managed by IBM while ai-accelerator is primarily for self-managed clusters. In order to get ai-accelerator to play nice with the ROKS cluster certain resources had to be tweaked by the kustomize configurations we put in place. 

Below you will find key points that allowed us to bring the two into harmony:

### Getting over ROKS' ValidatingAdmissionsPolicy ''ibm-operators-subscriptions-policy''

If one tries to install Red Hat Openshift AI on a ROKS cluster the conventional way (i.e. A Subscription that fetches content from Red Hat's out of the box catalog sources) then they will find the Subscription outputting the following error in its status object.

```
subscriptions.operators.coreos.com "rhods-operator" is forbidden: ValidatingAdmissionsPolicy ''ibm-operators-subscriptions-policy'' with binding
''ibm-operators-subscriptions-policy'' denied request: You must install rhods-operator as a managed Red Hat OpenShift on IBM Cloud add-on. 
See https://cloud.ibm.com/docs/openshift?topic=openshift-managed-addons for more information.
```

The reason for this is that ROKS has a particular way of installing RHOAI. You can read more on installing rhoai through ibm clouds cli [here](https://cloud.ibm.com/docs/openshift?topic=openshift-ai-addon-install&interface=cli) and how to manage it thereafter [here](https://cloud.ibm.com/docs/openshift?topic=openshift-ai-addon-manage&interface=ui).

The workaround to getting ai-accelerator to play nice with ibmcloud ROKS is two fold:
1. Make sure that ibm's catalog source exists on the ROKS cluster by running the following commands:
```
$ oc patch operatorhub cluster --type json -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": false}]'
$ ibmcloud oc cluster addon options --addon openshift-ai
```
2. Point the Red Hat Openshift AI operator Subscription to ibm catalog source like so:
```
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  annotations:
    argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
  name: rhods-operator
  namespace: redhat-ods-operator
spec:
...
  source: custom-redhat-operators-openshiftai
  sourceNamespace: redhat-ods-operator
```

### Getting over Red Hat OpenShift AI add-on naming.

The ROKS Red Hat OpenShift AI add-on has a number of resources (Subscriptions, OperatorGroups, etc) that are named differently compared to conventionally what comes with RHOAI and it's supporting operators (NVIDIA GPU Operator, Openshift Pipelines Operator, Node Feature Discovery Operator, etc).

Below is a table summarizing the different names that we had to change in the kustomize configurations.

|Namespace (if applicable) | Kubenetes Custom Resource| Conventional Name | Patched Name |
|----------|----------|----------|----------|
|n/a|DataScienceCluster|default|default-dsc|
|nvidia-gpu-operator|OperatorGroup|gpu-operator-certified|nvidia-gpu-operator-group|
|openshift-nfd|OperatorGroup|nfd|openshift-nfd|
|redhat-ods-operator|OperatorGroup|rhods-operator-group|rhods-operator|
|openshift-operators|Subscription|openshift-pipelines-operator|openshift-pipelines-operator-rh|
|openshift-serverless|OperatorGroup|serverless-operator-group|openshift-serverless-bh62z|

To get the change in names we used kustomizes patching feature. To see an example in action checkout this kustomize file for openshift-ai operator where OperatorGroup and DataScienceCluster are patched [here](../../../components/operators/openshift-ai/aggregate/overlays/rhoai-ibmcloud-lab/kustomization.yaml).

Note: Keep in mind certain acronyms below:
* ROKS is short for Red Hat Openshift Kubernetes Service. You can read more [here](https://cloud.ibm.com/docs/openshift?topic=openshift-getting-started&utm_source=chatgpt.com).
* RHOAI is short for Red Hat Openshift AI. You can read more [here](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/2.19).
