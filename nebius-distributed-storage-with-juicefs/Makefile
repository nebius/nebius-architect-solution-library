include .env
export

source: 
	. ./env-nebius.sh
init: source
	terraform init
apply: source
	terraform apply -auto-approve
destroy:
	terraform destroy -auto-approve
redeploy:
	terraform destroy -auto-approve
	terraform apply -auto-approve
plan:
	terraform plan -out=tfplan

pack:
	packer build ./packer/.