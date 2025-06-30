#!/bin/bash

# --- Configuration ---
# The OpenShift project (namespace) where your model is deployed.
PROJECT_NAME="your-project-name"
# The name for the new service account that your application will use.
SERVICE_ACCOUNT_NAME="my-app-caller"
# The name of the RoleBinding manifest.
ROLE_BINDING_NAME="app-caller-view-binding"

# --- Script ---

# Create a directory to hold the GitOps manifests
mkdir -p gitops-manifests
echo "Created directory: gitops-manifests"

# --- 1. Create the Service Account Manifest ---
# This YAML file defines the service account we want to exist.
echo "Creating Service Account manifest..."
cat <<EOF > gitops-manifests/01_service_account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${PROJECT_NAME}
EOF

# --- 2. Create the Role Binding Manifest ---
# This YAML file gives the service account the 'view' role within the project.
# This allows it to see services and routes to find the model's endpoint.
echo "Creating Role Binding manifest..."
cat <<EOF > gitops-manifests/02_role_binding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${ROLE_BINDING_NAME}
  namespace: ${PROJECT_NAME}
subjects:
- kind: ServiceAccount
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${PROJECT_NAME}
roleRef:
  kind: ClusterRole
  name: view # Using the built-in 'view' role
  apiGroup: rbac.authorization.k8s.io
EOF

echo ""
echo "--------------------------------------------------------------------"
echo "Success! Your GitOps manifests have been created in the 'gitops-manifests' directory."
echo ""
echo "Next Steps:"
echo "1. Replace 'your-project-name' in this script with your actual project name and re-run."
echo "2. Commit the 'gitops-manifests' directory to your Git repository."
echo "3. Your GitOps tool (Argo CD, Flux) will automatically apply these configurations to your cluster."
echo "4. Use the 'test_model_access.sh' script to verify the setup."
echo "--------------------------------------------------------------------"

