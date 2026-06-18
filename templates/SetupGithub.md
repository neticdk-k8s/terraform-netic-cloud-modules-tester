
## Azure : Create Service principal (Enterprise Applications)

# OS (OpenStack) user :  (OS_USERNAME/OS_PASSWORD)
# Go to public cloud / users&roles / Add user

# Projectname : Grap it at public cloud root page

# OVH User (OVH_APPLICATION_KEY etc)
## https://auth.eu.ovhcloud.com/api/createToken
## sæt alle (put/get ect) til *

# Lav storage container
# Download openrc.sh på bruger og kør : 'Source ~/Downloads/openrc.sh'   angiv password for Openstack User genereret ovenfor

ovhcloud login

# --- Configuration S3 ---
REGION=GRA
BUCKET_NAME=terraform-state-tbr
CONTAINER_ROLE="readWrite"
USER_DESC="terraform-state-tbr"

# --- 1. Create a dedicated Public Cloud user with the object storage role ---
# objectstore_operator"is the project role granting Object Storage access.

ovhcloud cloud user create  --cloud-project "$PROJECT_ID" --description "$USER_DESC" --roles objectstore_operator --output 'id'

# --- 2. Create the S3-compatible container ---
ovhcloud cloud storage object create "$REGION" --cloud-project "$PROJECT_ID" --name "$BUCKET_NAME"

# -- 3. Get user ID from above if step 1 does not have user id
USER_ID=$(ovhcloud cloud user list --cloud-project "$PROJECT_ID" --filter 'description=="'"$USER_DESC"'"' --output 'id')

# --- 4. Generate S3 credentials (access key + secret key) for that user ---
CRED=$(ovhcloud cloud storage object credentials create "$USER_ID"  --cloud-project "$PROJECT_ID"  --output json)

export AWS_ACCESS_KEY_ID=$(echo "$CRED" | jq -r '.access')
export AWS_SECRET_ACCESS_KEY=$(echo "$CRED" | jq -r '.secret')
export AWS_REGION="$(echo "$REGION" | tr '[:upper:]' '[:lower:]')"  # Lowercase

## Update User access policy for S3 user
cat << EOF > policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
            "Resource": ["arn:aws:s3:::${BUCKET_NAME}"]
        },
        {
            "Effect": "Allow",
            "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
            "Resource": ["arn:aws:s3:::${BUCKET_NAME}/*"]
        }
    ]
}
EOF

# Apply the policy to the user, passing the file contents inline
ovhcloud cloud user s3-policy create "$USER_ID" --cloud-project "$PROJECT_ID" --policy "$(cat policy.json)"

### Generate SSL Private key
# below I use already generated key

ssh-keygen -t ed25519 -C "flux@netic-k8s-test" -f ./flux-deploy-key -N ""
export TF_VAR_gitops_ssh_key="$(cat ./flux-deploy-key)"


#####
##### Samlet
#####

export REPO=neticdk-k8s/terraform-netic-cloud-modules-tester

export ARM_CLIENT_ID=
export ARM_CLIENT_SECRET=
export ARM_TENANT_ID="7eb9851d-6cba-497a-b8c5-905f362af323"
export ARM_SUBSCRIPTION_ID="9cbb71c9-7f62-4277-a708-f89d1f020134"

export OVH_ENDPOINT="ovh-eu"
export OVH_APPLICATION_KEY=
export OVH_APPLICATION_SECRET=
export OVH_CONSUMER_KEY=


export PROJECT_ID="bb219a2fd02c487798bbb0b349f622a5"
export OS_USERNAME=
export OS_PASSWORD=
export OVH_ENDPOINT="ovh-eu"

export TF_VAR_netic_git_username=
export TF_VAR_netic_git_token=
read -r -d '' TF_VAR_gitops_ssh_key <<'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
xxx
-----END OPENSSH PRIVATE KEY-----
EOF
export TF_VAR_gitops_ssh_key


gh auth login
gh repo view

echo "$ARM_CLIENT_ID"| gh secret set ARM_CLIENT_ID --repo "$REPO"
echo "$ARM_CLIENT_SECRET"| gh secret set ARM_CLIENT_SECRET --repo  "$REPO"
echo "$ARM_TENANT_ID"| gh variable set ARM_TENANT_ID --repo  "$REPO"
echo "$ARM_SUBSCRIPTION_ID"| gh variable set ARM_SUBSCRIPTION_ID --repo  "$REPO"


echo "$PROJECT_ID" | gh variable set PROJECT_ID  --repo "$REPO"
echo "$OS_USERNAME" | gh secret set OS_USERNAME --repo  "$REPO"
echo "$OS_PASSWORD"| gh secret set OS_PASSWORD --repo  "$REPO"
echo "$OVH_ENDPOINT"  | gh variable set OVH_ENDPOINT --repo  "$REPO"

echo "$OVH_ENDPOINT" |  gh secret set OVH_ENDPOINT --repo  "$REPO"
echo "$OVH_APPLICATION_KEY" |  gh secret set OVH_APPLICATION_KEY --repo  "$REPO"
echo "$OVH_APPLICATION_SECRET"|  gh secret set OVH_APPLICATION_SECRET --repo  "$REPO"
echo "$OVH_CONSUMER_KEY" |  gh secret set OVH_CONSUMER_KEY --repo  "$REPO"

echo "$BUCKET_NAME" | gh variable set BUCKET_NAME --repo  "$REPO"
echo "$AWS_ACCESS_KEY_ID" |  gh secret set AWS_ACCESS_KEY_ID --repo  "$REPO"
echo "$AWS_SECRET_ACCESS_KEY" | gh secret set AWS_SECRET_ACCESS_KEY --repo  "$REPO"
echo "$AWS_REGION" |  gh secret set AWS_REGION --repo  "$REPO"


gh variable list --repo  "$REPO"
gh secret list --repo  "$REPO"


