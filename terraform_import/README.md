# learn_terraform
Learning and experimenting with Terraform for Infrastructure as Code (IaC).

### Terraform Commands

```bash
# terraform intialize 
terraform init

# formating the code 
terraform fmt

# alingment check
terraform fmt -check

# formate the code inside the folders
terraform fmt -recursive

#validate
terraform validate

# plan it shows what are things are there to do  
terraform plan

# import the s3 buckets 
terraform import aws_s3_bucket.application_data_bucket  

#apply -- it will create all the values 
terraform apply 

#output show the output of the teraform 
terraform output

#destroy 
terraform destroy 
```