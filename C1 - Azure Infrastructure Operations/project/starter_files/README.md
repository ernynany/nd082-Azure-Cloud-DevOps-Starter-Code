# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started
1. Clone this repository

2. Create your infrastructure as code

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions
To replicate this project, do the following:
* first create a resource group on azure
* create a tagging policy to deny resource created with no tags
* create a ubuntu server image template with Packer
* create your infrastrute with terraform
* run the following commands to deploy your infrastructure:
- terraform init
- terraform validate
- terraform plan -out solution.plan
- terraform apply -auto-approve

### Output
After terraform apply, you are expected to have this output upon successful application:

azurerm_virtual_machine.main[0]: Creation complete after 48s [id=/subscriptions/cd76ddea-1764-45da-9592-9479ad9ec051/resourceGroups/packer-project1/providers/Microsoft.Compute/virtualMachines/UdacityProject1VM-0]

Apply complete! Resources: 15 added, 0 changed, 14 destroyed.

Outputs:

id = "/subscriptions/cd76ddea-1764-45da-9592-9479ad9ec051/resourceGroups/packer-project1"
image_id = "/subscriptions/cd76ddea-1764-45da-9592-9479ad9ec051/resourceGroups/packer-project1/providers/Microsoft.Compute/images/UbuntuServer-Udacity"
root@DESKTOP-ND8EM2D:~/udacity#

Note: your output might be a little different from what we have here!
