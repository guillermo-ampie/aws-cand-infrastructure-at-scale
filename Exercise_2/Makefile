init:
	terraform init

validate:
	terraform validate

fmt:
	terraform fmt

lint:
	@echo "TFLint: https://github.com/terraform-linters/tflint"
	tflint 

plan: lint
	terraform plan

deploy: lint
	terraform apply -auto-approve

ls:
	aws s3 ls `terraform output -raw lambda_bucket_name` --recursive

clean:
	terraform destroy -auto-approve
