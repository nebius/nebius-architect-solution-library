# Nebius NFS Module

This Terraform module provisions an NFS server on Nebius Cloud. It creates a virtual machine with a secondary disk attached, formats the disk, and sets up an NFS server that exports the disk as an NFS share.

## Module Structure

The module includes the following files and directories:

- `main.tf` - The main Terraform configuration file for the module.
- `variables.tf` - Definitions of variables used within the module.
- `outputs.tf` - Outputs after the module has been applied.
- `provider.tf` - The provider configuration file (to be filled in with your provider's details).
- `files/`
  - `cloud-config.sh` - A shell script that initializes the NFS server on the virtual machine.


## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

```
export YC_TOKEN=$(ncp iam create-token)
```


## Usage


To use this module in your Terraform environment, you will need to create a Terraform configuration for example file `terraform.tfvars` with example conent:

```hcl
folder_id = "<folder_id>" # folder where you want to create your resources
subnet_id = "<subnet_id>" # subnet_id where the VM should be created
nfs_size = "930" # must be divisible by 93
nfs_ip_range = "<internal_network>" # network address, eg 10.0.0.0/16, where you want you NFS share to be accessible
sshkey = "<ssh_key>"
```

Then you can mount on your target device using command 
```bash
sudo apt-get install nfs-common
sudo mount <ip_address>:/nfs /nfs
```

To get best perfomance from the network you may change MTU to 8910. For Ubuntu 22.04 LTS:
```bash
netplan set ethernets.eth0.mtu=8910
netplan apply
```
