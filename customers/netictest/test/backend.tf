# Defines where Terraform statefile is locateds

# By defining this in seperate file, it is easy in a terraform to point to different environments and 
# use same providers.tf, but seperate backend.tf :
#   terraform init -backend-config="..."

terraform {
  backend "s3" {
    bucket = "tf-state-netictest-test2"
    key    = "terraform.tfstate" 
    region = "bhs" 
    
    endpoints = {
      s3 = "https://s3.bhs.io.cloud.ovh.net"
    }
    
    # Vitale indstillinger til OVH S3 (OpenIO)
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}