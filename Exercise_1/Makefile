init:
	terraform init

validate:
	terraform validate

format:
	terraform fmt

lint:
	@echo "TFLint: https://github.com/terraform-linters/tflint"
	tflint 

plan: lint
	terraform plan

build: lint
	terraform apply -auto-approve

clean:
	terraform destroy -auto-approve
