# ArgoCD

In this document you will find settings that were chosen for the ArgoCD instance and sections on how to change them.

## ArgoCD Setup

The starting kustomize folder of the default argocd configuration and settings inherited from ai-accelerator are located [here](https://github.com/redhat-ai-services/ai-accelerator/tree/main/components/operators/openshift-gitops/aggregate/overlays/rhdp)

The resulting argocd configuration is located at the following folder locations:
* [Aggregates the operator configuration as well as the argocd/gitops instance application yaml content](https://github.com/ardiangroupinc/ai-accelerator/tree/main/components/operators/openshift-gitops/aggregate/overlays/rhoai-ibmcloud-lab)
* [Defines the Argocd Applications for the app of apps](https://github.com/ardiangroupinc/ai-accelerator/tree/main/components/argocd/apps/overlays/rhoai-ibmcloud-lab).

Some key points are as follows:
1. The app of apps pattern was chosen as a Gitops strategy. Information on what that pattern is can be found [here](https://argo-cd.readthedocs.io/en/latest/operator-manual/cluster-bootstrapping/) and [here](https://github.com/gnunn-gitops/standards/blob/master/folders.md). After `bootstrap.sh` is ran the first thing it does is setup argocd with this structure presupposing this Gitops strategy.
    1. The root application or the "app" of the "app of apps pattern" can be seen [here](../components/argocd/apps/base/cluster-config-app-of-apps.yaml) and its teaks can be found [here](../components/argocd/apps/overlays/rhoai-ibmcloud-lab/patch-cluster-config-app-of-apps.yaml). 
    1. Each of the operators supporting ai/ml development is treated as one of the "apps" in the "app of apps pattern". The way the set of apps gets created is through the ApplicationSet located [here](../components/argocd/apps/base/cluster-operators-applicationset.yaml) along with its tweaks [here](../components/argocd/apps/base/cluster-operators-applicationset.yaml). From the [overlays yaml](../components/argocd/apps/base/cluster-operators-applicationset.yaml) we can see that authorino-operator, nvidia-gpu-operator, nfd-operator, openshift-ai-operator, openshift-gitops-operator, openshift-pipelines-operator, openshift-serverless-operator, and  openshift-servicemesh-operator are all generated as ArgoCD applications. The respective kustomize content for each operator argo cd application can be found in the path field of the [overlays yaml file](https://github.com/ardiangroupinc/ai-accelerator/tree/main/components/argocd/apps/overlays/rhoai-ibmcloud-lab).
    1. The next set of "apps" in the "app of apps pattern" is cluster-configs that we wanted to put on the cluster but we did not have any for our engagement so we set the list elements field for that ApplicaitionSet to empty as seen in the [overlays yaml file](../components/argocd/apps/base/cluster-configs-applicationset.yaml). However if we wanted to add a "cluster configuration" such as user workload monitoring or cluster autoscaling, we could put it here.
    1. The last set of "apps" in the "app of apps pattern" is the one for "tenants". The kustomize configuration scans for folders under paths that follow this format `tenants/*/*/overlays/rhoai-ibmcloud-lab` and can be seen [here](../components/argocd/apps/base/tenants-applicationset.yaml). For instance, as an example we have a folder called `redhat-team`. They are a tenant of our `rhoai-ibmcloud-lab` cluster. In other words they are persons that want to use our cluster resources for a particular purpose of demonstrating examples to ArdianGroup and so the folder "redhat-team" would have all the kubernetes resources (namespaces, workbenches, data connections, etc) grouped by folder. For instance they could be interested in having certain namespaces on the cluster so they have `tenants/redhat-team/namespaces/base` for the base namespaces and `tenants/redhat-team/namespaces/overlays/rhoai-ibmcloud-lab/*.yaml` for any tweaks they want to make to those base namespaces on the `rhoai-ibmcloud-lab` cluster instance. Likewise for other resources such as "data-science-pipelines", "mino", "workbenches", etc they would have the appropriate folders. If they wanted these resources under a different cluster lab say for aws, it would theoretically look like `tenants/redhat-team/namespaces/overlays/rhoai-aws-lab/*.yaml`. The tenants can also be conceptualized not as arbitrary team resources for any aribitrary purpose but rather the tenant team having their own argo setup with that team worrying about what gitops strategy they use for a particular cluster. This `tenants` folder can be used in whatever strategy is good for your tenants or if you don't want "tenants" to be managed in this way you can set that folder to empty as we did with the cluster-configs argocd application.

Below are some other key tweaks we made for the argocd instance on `rhoai-ibmcloud-lab` cluster:
1. We severed the fork between ai-accelerator and our fork of it. Why? Because that project is very generic and has a lot of documentation and settings that would distract our efforts. For instance it has many bootstrap options for aws that is very opinionated even though we don't have an aws cluster. If we want to adopt one of those options we can simply look at the upstream bootstrap folder.
1. The autosync of all the argocd Applications has been disabled. In other words if we make changes in our ai-accelerator git repository that affect some argocd application, the changes will be detected by our argocd instance but won't automatically `oc apply ...` it to our cluster. Instead argodcd waits for a human operator to go in the ArgoCD ui and click the sync button to sync the right resources. The reason this was chosen was so we could have more control over the deployment process. Also when cluster errors occur it can be a distraction if a user is manuallly making changes on the cluster only to fight with the ArgoCD reconciler putting them back to the desired state. Still even a third reason for this is that having the reconciler on can be a source of paranoia in terms of what may be causing future issues on the cluster. By eliminating the reconciler from the picture, a troubleshooter can be more confident that the reconciler is not the cause of the issue. CAUTION: Always remember that if you make changes on the cluster without putting them in Git first, there is a chance that when the operator manually syncs things they might select prune or replace, causing your changes to be lost. So keep this in mind. An example of turning off the sync can be seen [here](../clusters/overlays/rhoai-ibmcloud-lab/patch-application-manual-sync.yaml). You can read more about ArgoCD autosyncing feature [here](https://argo-cd.readthedocs.io/en/latest/user-guide/sync-options/).
1. All operator subscriptions have a `installPlanApproval` of Automatic except for the `nvidia-gpu-operator` which is set to `Manual`. Automatic means that the operator will automatically approve it's own install plan and carry it out when a newer MINOR or PATCH version of the operator is discovered by Operator Lifecycle Manager (OLM for short). You can read more aobut Openshift update strategy [here](https://www.redhat.com/en/blog/the-ultimate-guide-to-openshift-update-for-cluster-administrators#:~:text=OpenShift%20follows%20a%20semantic%20versioning,We'll%20cover%20them%20below.). We chose Automatic so as to be more concerned with just using the product first and setting to Manual when issues come up. For instance, `nvidia-gpu-operator` has a special update process that might result in choking current gpu workloads during the update process and lead to a vicious update loop where the gpu stack is not able to be properly installed by `daemonset.apps/nvidia-driver-daemonset-417.94.202506022342-0` and its pods. A better approach for this operator is to wait during periods of down time where nobody needs the gpu and then accept the installplan manually so as to update the gpu stack. You can read more about this process [here](https://docs.nvidia.com/datacenter/cloud-native/openshift/25.3.0/troubleshooting-gpu-ocp.html#verify-the-nvidia-driver-deployment).
1. To understand the folder structure we chose to adopt please see this [document](https://github.com/gnunn-gitops/standards/blob/master/folders.md ).
1. The original ai-accelerator comes with many examples that we deleted from this repository because they hindered reading and navigation throughout the folder structure. However if you are interested in one of the examples, please look [here](https://github.com/redhat-ai-services/ai-accelerator/tree/main/tenants/ai-example).
1. In terms of overlays folder naming, we chose the folder name `rhoai-ibmcloud-lab`. rhoai indicates we are interested in deploying resources related to ai/ml development with redhat openshift ai product, ibmcloud indicates we are on the cloud provider ibm cloud, and lab indicates this is for lab concerns such as learning about the rhoai product, experimenting with ai/ml models, and showcasing some consumption of these ai/ml applications by some ArdianGroup clients.
1. Another choice that was made was to have the main ArdianGroup team and redhatters have cluster administrator role on the gitops server with the datascientists being barred from access. The list of people added as cluster admins can be seen [here](components/operators/openshift-gitops/instance/overlays/rhoai-ibmcloud-lab/kustomization.yaml) and [here](components/operators/openshift-gitops/instance/overlays/rhoai-ibmcloud-lab/gitops-admins-group.yaml).
1. A final note on these choices, is that this is meant to be a starting point not a final ending point. This strategy inherently respects an iterative process or trial and error approach. If something doesn't workout we can make choices to change the overrall strategy.


## ArgoCD Howtos

### Updating the ArgoCD Groups

Argo creates the following group in OpenShift to grant access and control inside of ArgoCD:

- gitops-admins

Conventionally to add a user to the admin group one manually runs `oc adm groups add-users gitops-admins $(oc whoami)` or to add a user to the user group run one manually runs `oc adm groups add-users argocdusers $(oc whoami)`. Once the user has been added to the group logout of Argo and log back in to apply the updated permissions. Validate that you have the correct permissions by going to `User Info` menu inside of Argo to check the user permissions.

However, the whole point of Gitops is to make changes to the system through git. So the appropriate way is to update this [file](components/operators/openshift-gitops/instance/overlays/rhoai-ibmcloud-lab/gitops-admins-group.yaml) with the person you want to have that kind of access. Next go into [ArgoCD](https://openshift-gitops-server-openshift-gitops.voicd-us-east-3-4cb626ac15bdff235c2f3fba02223e28-0000.us-east.containers.appdomain.cloud/applications) and hit the "Refresh Apps" button. Refresh all the apps in the prompt that comes up. This will notify each of the Argo Applications to look at the remote git and see if it has drifted from what is in their respective git repositories for that application. You will see some out of sync application messages afterwards. Click on the appropariate argo application in this case `openshift-gitops-operator`. Hit the "Sync" button to bring the actual/deployed/live state on the `rhoai-ibmcloud-lab` cluster to the desired state stored in git. Now the new user should have been added as a gitops admin on the cluster.

### Accessing Argo using the CLI

To log into ArgoCD using the `argocd` cli tool run the following command:

```sh
argocd login --sso <argocd-route> --grpc-web
```

### ArgoCD Troubleshooting

#### Operator Shows Progressing for a Very Long Time

ArgoCD Symptoms:

Argo Applications and the child subscription object for operator installs show `Progressing` for a very long time.

Explanation:

Argo utilizes a `Health Check` to validate if an object has been successfully applied and updated, failed, or is progressing by the cluster.  The health check for the `Subscription` object looks at the `Condition` field in the `Subscription` which is updated by the `OLM`.  Once the `Subscription` is applied to the cluster, `OLM` creates several other objects in order to install the Operator.  Once the Operator has been installed `OLM` will report the status back to the `Subscription` object.  This reconciliation process may take several minutes even after the Operator has successfully installed.

Resolution/Troubleshooting:

- Validate that the Operator has successfully installed via the `Installed Operators` section of the OpenShift Web Console.
- If the Operator has not installed, additional troubleshooting is required.
- If the Operator has successfully installed, feel free to ignore the `Progressing` state and proceed.  `OLM` should reconcile the status after several minutes and Argo will update the state to `Healthy`.
