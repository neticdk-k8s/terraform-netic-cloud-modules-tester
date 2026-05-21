## IN progress.   storage-s3 does noet exists.    aws command can not control rights.  

## to do - how to upload json with rights from shell
# https://github.com/ovh/ovhcloud-cli/blob/main/doc/ovhcloud_cloud_storage_object_add-user.md

#!/bin/bash
# (brew install openstackclient)
# brew install --cask ovh/tap/ovhcloud-cli
# brew install awscli

# Read openrc file
#  - Go to public cloud / Users & Roles  / ... on user and download OpenStack RC file

# run
#   source openrc.sh
# and specify password # WRvKZwJJvmWdFwRyJ3N9vS6hDkTdNRFg

# Stop scriptet hvis en kommando fejler
set -e

# Konfiguration - Tilpas disse til dit behov
CUSTOMER="netictest"
PROJECTID="d8a148f6b2d5406b9ac340e25faa50ad"
ENVIRONMENT="test2"
REGION="BHS" # f.eks. GRA, SBG, WAW alt efter hvor dit projekt lever
CONTAINER_NAME="tf-state-${CUSTOMER}-${ENVIRONMENT}"

export OVH_ENDPOINT="ovh-ca"
export OVH_APPLICATION_KEY="4629e51cfd387621"
export OVH_APPLICATION_SECRET="2497b42ead55ea8af6d4cb76ca88d50f"
export OVH_CONSUMER_KEY="a6537c9641f0d55fc5f299f3455be0c6"

# 1. Tjek om OpenStack variabler er indlæst
if [ -z "$OS_AUTH_URL" ]; then
    echo "❌ Fejl: OpenStack-miljøvariabler ikke fundet!"
    echo "Husk at køre: source /stien/til/din/openstack.rc"
    exit 1
fi

# 2. Sikkerhedstjek: Er 'jq' installeret til at læse JSON?
if ! command -v jq &> /dev/null; then
    echo "❌ Fejl: 'jq' er ikke installeret. Kør: brew install jq"
    exit 1
fi

cat << 'EOF' > policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": ["s3:ListBucket", "s3:GetBucketLocation"],
            "Resource": ["arn:aws:s3:::state2"]
        },
        {
            "Effect": "Allow",
            "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
            "Resource": ["arn:aws:s3:::state2/*"]
        }
    ]
}
EOF

ovhcloud cloud storage object add-user state2 hep <role (admin, deny, readOnly, readWrite)>

ovhcloud cloud storage object credentials create test  --cloud-project "$PROJECTID" \
  --name "$CONTAINER_NAME" \
  --region "$REGION" \
  --pro

ovhcloud cloud storage object credentials create 
  --cloud-project "$PROJECTID" \
  --name "$CONTAINER_NAME" \
  --region "$REGION"

ovhcloud cloud storage object user policy update \
  --cloud-project "DIT_OVH_PROJECT_ID" \
  --user-id "DIT_S3_USER_ID" \
  --policy-file policy.json



# 3. Generer officielle S3/EC2-credentials direkte fra Keystone
echo "Create S3 keys..."
USER_CREDS=$(openstack ec2 credentials create -f json)

ACCESS_KEY=$(echo "$USER_CREDS" | jq -r '.access')
SECRET_KEY=$(echo "$USER_CREDS" | jq -r '.secret')

echo "Create Terraform State Store on OVHcloud..."
echo "Customer: $CUSTOMER | Environment: $ENVIRONMENT | Region: $REGION"

ovhcloud login
ovhcloud cloud storage object create BHS --name "$CONTAINER_NAME"  --cloud-project "$PROJECTID" 
ovhcloud cloud storage object list --cloud-project "$PROJECTID" 

# --object-lock-status enabled --object-lock-rule-mode compliance --object-lock-rule-period P30D


aws s3api create-bucket \
  --bucket "state2" \
  --endpoint-url "https://s3.bhs.io.cloud.ovh.net" \
  --region "bhs"


ovhcloud cloud project storage object create \
  --cloud-project "$PROJECTID" \
  --name "$CONTAINER_NAME" \
  --region "$REGION"


# 2. Opret Swift containeren i den rigtige region
echo "Create Container : $CONTAINER_NAME..."
openstack --os-region-name "$REGION" container create "$CONTAINER_NAME"

# Bemærk: Swift containere er private som standard i OVH, 
# så dine state-filer er låst helt af for omverdenen.

echo "Succes! Container '$CONTAINER_NAME' is ready."
echo "=================================================================="
echo ""
echo "1️⃣ Kopier disse to linjer ind i din 'backend.tfvars':"
echo "------------------------------------------------------------------"
echo "access_key = \"$ACCESS_KEY\""
echo "secret_key = \"$SECRET_KEY\""
echo "------------------------------------------------------------------"
echo ""
echo "2️⃣ Brug denne præcise opsætning i din 'provider.tf':"
echo "------------------------------------------------------------------"
echo "terraform {"
echo "  backend \"s3\" {"
echo "    bucket   = \"$CONTAINER_NAME\""
echo "    key      = \"terraform.tfstate\""
echo "    region   = \"gra\"                           # Påkrævet til OVH signatur-validering"
echo "    endpoint = \"https://s3.bhs.io.cloud.ovh.net\" # Trafikken sendes direkte til Canada"
echo ""
echo "    skip_credentials_validation = true"
echo "    skip_region_validation      = true"
echo "    skip_requesting_account_id  = true"
echo "    skip_metadata_api_check     = true"
echo "  }"
echo "}"
echo "------------------------------------------------------------------"