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

run-lambda:
	aws lambda invoke --region=`terraform output -raw aws_region` --function-name=`terraform output -raw lambda_function_name` out.txt
	@echo
	@echo "output from lambda:"
	cat out.txt

clean:
	terraform destroy -auto-approve
	-rm -r ./lambda

