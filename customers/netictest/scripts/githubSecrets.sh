##  brew install gh

export OVH_TENANTID="?
export OVH_APPLICATION_KEY="?
export OVH_APPLICATION_SECRET=?
export OVH_CONSUMER_KEY=?
export OVH_ENDPOINT="ovh-ca" 

export AWS_ACCESS_KEY_ID=?
export AWS_SECRET_ACCESS_KEY=?

export OS_USERNAME="user-m2VqfAnNGsuh"
export OS_PASSWORD= ?


gh auth login

gh repo view

echo "$OVH_TENANTID"| gh secret set OVH_TENANTID --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_APPLICATION_KEY"| gh secret set OVH_APPLICATION_KEY --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_APPLICATION_SECRET"| gh secret set OVH_APPLICATION_SECRET --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_CONSUMER_KEY"| gh secret set OVH_CONSUMER_KEY --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_ENDPOINT"| gh variable set OVH_ENDPOINT --repo neticdk-k8s/terraform-netic-ovhcloud 

echo "$AWS_ACCESS_KEY_ID" | gh secret set AWS_ACCESS_KEY_ID --repo neticdk-k8s/terraform-netic-ovhcloud
echo "$AWS_SECRET_ACCESS_KEY" | gh secret set AWS_SECRET_ACCESS_KEY --repo neticdk-k8s/terraform-netic-ovhcloud

## OpenStack for storage
echo "$OS_USERNAME" | gh secret set OS_USERNAME --repo neticdk-k8s/terraform-netic-ovhcloud
echo "$OS_PASSWORD" | gh secret set OS_PASSWORD --repo neticdk-k8s/terraform-netic-ovhcloud

gh variable list --repo neticdk-k8s/terraform-netic-ovhcloud 
gh secret list --repo neticdk-k8s/terraform-netic-ovhcloud 
