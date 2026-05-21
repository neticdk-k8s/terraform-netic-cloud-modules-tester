
# Deploy Infrastructure

terraform init
terraform plan -var-file="variables.tfvars"

terraform apply -var-file="variables.tfvars" -auto-approve

terraform destroy -var-file="variables.tfvars"  -auto-approve  


## Output

Data like passwords are sensitive, and will not be shown.  

Run 
```Terraform output password```
to get the password
