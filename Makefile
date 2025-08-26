# Homelab GitOps Makefile
# Simplifies common development and deployment tasks

.PHONY: help validate plan apply destroy ansible-check ansible-deploy clean status

# Default target
help:
	@echo "🏠 Homelab GitOps Infrastructure Management"
	@echo "==========================================="
	@echo "📖 Repository: https://github.com/piyush97/homelab-gitops"
	@echo ""
	@echo "Available targets:"
	@echo "  help             - Show this help message"
	@echo "  validate         - Validate all configurations"
	@echo "  plan             - Generate Terraform execution plan"
	@echo "  apply            - Apply Terraform configuration"
	@echo "  destroy          - Destroy Terraform infrastructure"
	@echo "  ansible-check    - Check Ansible configuration"
	@echo "  ansible-deploy   - Deploy with Ansible"
	@echo "  status           - Show infrastructure status"
	@echo "  clean            - Clean temporary files"
	@echo ""
	@echo "Requirements:"
	@echo "  - Terraform >= 1.6.0"
	@echo "  - Ansible >= 2.9"
	@echo "  - Access to Proxmox VE host"

# Validate all configurations
validate:
	@echo "🔍 Validating infrastructure configuration..."
	@./scripts/validate-infrastructure.sh

# Terraform operations
plan:
	@echo "📋 Generating Terraform execution plan..."
	@cd terraform && terraform init && terraform plan -out=tfplan

apply:
	@echo "🚀 Applying Terraform configuration..."
	@cd terraform && terraform apply tfplan
	@echo "✅ Infrastructure deployment completed!"

destroy:
	@echo "💥 WARNING: This will destroy all infrastructure!"
	@echo "Press Ctrl+C to cancel or Enter to continue..."
	@read
	@cd terraform && terraform destroy -auto-approve

# Ansible operations  
ansible-check:
	@echo "🔍 Checking Ansible configuration..."
	@cd ansible && ansible-playbook playbooks/site.yml --check --diff

ansible-deploy:
	@echo "⚙️ Deploying configuration with Ansible..."
	@cd ansible && ansible-playbook playbooks/site.yml --diff

# Infrastructure status
status:
	@echo "📊 Infrastructure Status"
	@echo "======================="
	@echo ""
	@echo "Terraform State:"
	@cd terraform && terraform show -json | jq -r '.values.root_module.child_modules[].resources[] | "\(.address): \(.values.hostname // "N/A")"' 2>/dev/null || echo "Run 'make plan' first"
	@echo ""
	@echo "Container Status:"
	@cd ansible && ansible all -m shell -a "pct status \$$(hostname | cut -d'-' -f2)" 2>/dev/null || echo "Run 'make ansible-deploy' first"

# Clean temporary files
clean:
	@echo "🧹 Cleaning temporary files..."
	@find . -name "*.tfplan" -delete
	@find . -name "*.retry" -delete
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name "validation-report.md" -delete
	@echo "✅ Cleanup completed"

# Development helpers
tf-fmt:
	@echo "🎨 Formatting Terraform files..."
	@cd terraform && terraform fmt -recursive

ansible-lint:
	@echo "🔍 Linting Ansible configuration..."
	@cd ansible && ansible-lint playbooks/site.yml

# Full deployment workflow
deploy: validate plan apply ansible-deploy
	@echo "🎉 Full deployment completed successfully!"
	@echo ""
	@echo "Next steps:"
	@echo "1. Verify services are running: make status"
	@echo "2. Check monitoring dashboards"
	@echo "3. Test service connectivity"

# Emergency stop all containers
emergency-stop:
	@echo "🛑 EMERGENCY: Stopping all containers..."
	@cd ansible && ansible all -m shell -a "pct stop \$$(hostname | cut -d'-' -f2)" --become

# Show container IPs
show-ips:
	@echo "🌐 Container IP Addresses"
	@echo "========================"
	@cd ansible && ansible-inventory --list --yaml | grep -A1 "ansible_host:" | grep -v "^--"