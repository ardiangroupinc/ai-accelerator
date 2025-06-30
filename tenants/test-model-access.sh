#!/bin/bash

# --- Configuration ---
# The OpenShift project (namespace) where your model is deployed.
PROJECT_NAME="your-project-name"
# The name of the service account created by your GitOps process.
SERVICE_ACCOUNT_NAME="my-app-caller"
# The full URL for your model's inference endpoint.
# Get this from the OpenShift AI dashboard.
INFERENCE_URL="your-inference-url-here"
# The name of the model you are calling.
MODEL_NAME="your-model-name"

# --- Validation ---
if [[ "$PROJECT_NAME" == "your-project-name" || "$INFERENCE_URL" == "your-inference-url-here" ]]; then
  echo " Error: Please edit this script and fill in your actual PROJECT_NAME and INFERENCE_URL."
  exit 1
fi

# --- Script ---

echo "Attempting to get a token for service account '${SERVICE_ACCOUNT_NAME}' in project '${PROJECT_NAME}'..."

# --- 1. Get the Authentication Token ---
# This command generates a temporary token for the service account.
TOKEN=$(oc -n ${PROJECT_NAME} create token ${SERVICE_ACCOUNT_NAME})

if [ -z "$TOKEN" ]; then
    echo " Error: Failed to retrieve token. Please check the following:"
    echo "   - Are you logged into OpenShift ('oc whoami')?"
    echo "   - Does the project '${PROJECT_NAME}' exist?"
    echo "   - Did your GitOps tool successfully create the '${SERVICE_ACCOUNT_NAME}' service account?"
    exit 1
fi

echo " Token successfully retrieved."
echo ""

# --- 2. Make the Authenticated API Call ---
echo " Calling the model inference API..."
echo ""

curl -k --fail -X POST "${INFERENCE_URL}" \
-H "Authorization: Bearer ${TOKEN}" \
-H "Content-Type: application/json" \
-d '{
  "model": "'"${MODEL_NAME}"'",
  "messages": [
    {
      "role": "user",
      "content": "Generate the code for Hello world in C++"
    }
  ]
}'

# Check the exit code of the curl command
if [ $? -eq 0 ]; then
    echo ""
    echo ""
    echo " Success! The API call returned a valid response."
else
    echo ""
    echo ""
    echo " Error: The API call failed. Check the output from curl above for details."
fi

