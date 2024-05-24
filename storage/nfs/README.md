# Nebius NFS module

This Terraform module facilitates the provisioning of an NFS server on Nebius Cloud. It creates a virtual machine with a secondary disk, formats the disk, and configures an NFS server to export the disk as an NFS share.

## Module structure

The module includes the following files and directories:

- `main.tf` - main Terraform configuration file for the module.
- `variables.tf` - definitions for variables used within the module.
- `outputs.tf` - outputs obtained after the module has been applied.
- `provider.tf` - provider configuration file (to be filled out with your provider's details).
- `files/`
  - `cloud-config.sh` - shell script that initializes the NFS server on the virtual machine.


## Configuring Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart).
- Add environment variables for Terraform authentication in Nebuis Cloud.

```
export YC_TOKEN=$(ncp iam create-token)
```


## Usage

To use this module in your Terraform environment, you must first create a Terraform configuration, such as the file `terraform.tfvars`, with the following example content:

```hcl
folder_id = "<folder_id>" # folder where you want to create your resources
subnet_id = "<subnet_id>" # subnet_id where the VM should be created
nfs_size = "930" # must be divisible by 93
nfs_ip_range = "<internal_network>" # network address, eg 10.0.0.0/16, where you want you NFS share to be accessible
sshkey = "<ssh_key>"
```

Once you have done that, you can mount on your target device using command 
```bash
sudo apt-get install nfs-common
sudo mount <ip_address>:/nfs /nfs
```

To optimize network performance, consider changing the  MTU to 8910. For Ubuntu 22.04 LTS:
```bash
netplan set ethernets.eth0.mtu=8910
netplan apply
```