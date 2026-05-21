##  brew install gh

export OVH_TENANTID="d8a148f6b2d5406b9ac340e25faa50ad"  
export OVH_APPLICATION_KEY="4629e51cfd387621"
export OVH_APPLICATION_SECRET="2497b42ead55ea8af6d4cb76ca88d50f"
export OVH_CONSUMER_KEY="a6537c9641f0d55fc5f299f3455be0c6"
export OVH_ENDPOINT="ovh-ca" 

export AWS_ACCESS_KEY_ID="3caf29f739924d3ba1caa6f0f5099c8c"
export AWS_SECRET_ACCESS_KEY="b0ae14c6c83f4323b9fac14341d0ccc4"


gh auth login

gh repo view

echo "$OVH_TENANTID"| gh secret set OVH_TENANTID --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_APPLICATION_KEY"| gh secret set OVH_APPLICATION_KEY --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_APPLICATION_SECRET"| gh secret set OVH_APPLICATION_SECRET --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_CONSUMER_KEY"| gh secret set OVH_CONSUMER_KEY --repo neticdk-k8s/terraform-netic-ovhcloud 
echo "$OVH_ENDPOINT"| gh variable set OVH_ENDPOINT --repo neticdk-k8s/terraform-netic-ovhcloud 

echo "$AWS_ACCESS_KEY_ID" | gh secret set AWS_ACCESS_KEY_ID --repo neticdk-k8s/terraform-netic-ovhcloud
echo "$AWS_SECRET_ACCESS_KEY" | gh secret set AWS_SECRET_ACCESS_KEY --repo neticdk-k8s/terraform-netic-ovhcloud


gh variable list --repo neticdk-k8s/terraform-netic-ovhcloud 
gh secret list --repo neticdk-k8s/terraform-netic-ovhcloud 