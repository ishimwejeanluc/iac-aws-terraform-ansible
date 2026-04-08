#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
backend_dir="$repo_root/backend-boostrap"
terraform_dir="$repo_root/terraform"
ansible_dir="$repo_root/ansible"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform is not installed or not on PATH" >&2
  exit 1
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook is not installed or not on PATH" >&2
  exit 1
fi

auto_approve=true
apply_log="$repo_root/terraform-apply.txt"

echo "==> Terraform init for backend"
terraform -chdir="$backend_dir" init

echo "==> Terraform plan for backend"
terraform -chdir="$backend_dir" plan -out=tfplan

echo "==> Terraform apply for backend"
if $auto_approve; then
  terraform -chdir="$backend_dir" apply -auto-approve tfplan
else
  terraform -chdir="$backend_dir" apply tfplan
fi

s3_bucket_name=$(terraform -chdir="$backend_dir" output -raw s3_bucket_name)
dynamodb_table_name=$(terraform -chdir="$backend_dir" output -raw dynamodb_table_name)

echo "==> Terraform init for main configuration"
terraform -chdir="$terraform_dir" init \
  -backend-config="bucket=$s3_bucket_name" \
  -backend-config="key=terraform.tfstate" \
  -backend-config="region=us-west-1" \
  -backend-config="dynamodb_table=$dynamodb_table_name"

echo "==> Terraform apply for main configuration"
if $auto_approve; then
  terraform -chdir="$terraform_dir" apply -auto-approve -no-color | tee "$apply_log"
else
  terraform -chdir="$terraform_dir" apply -no-color | tee "$apply_log"
fi

inventory_file="$ansible_dir/inventory.ini"
playbook_file="$ansible_dir/site.yml"

if [[ ! -f "$inventory_file" ]]; then
  echo "Inventory not found: $inventory_file" >&2
  exit 1
fi

if [[ ! -f "$playbook_file" ]]; then
  echo "Playbook not found: $playbook_file" >&2
  exit 1
fi

echo "==> Ansible playbook"
ANSIBLE_HOST_KEY_CHECKING=False \
  ansible-playbook -i "$inventory_file" \
  --ssh-common-args "-o StrictHostKeyChecking=no" \
  "$playbook_file"
