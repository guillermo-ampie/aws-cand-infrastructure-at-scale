setup:
	@echo "Setup tflint..."
	tflint --init
	@echo "Setup terraform..."
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

clean:
	terraform destroy -auto-approve
