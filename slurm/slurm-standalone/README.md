# Nebius slurm management module

This Terraform module provisions a slurm cluster on Nebius Cloud. It orchestrates the creation of virtual machines for nodes and masters, configuring them to be operational and installs enroot and pyxis plugins, enabling the execution of container workloads.

## Module structure

The module includes the following files and directories:

- `main.tf` - The main Terraform configuration file for the module.
- `variables.tf` - Definitions for variables used within the module.
- `outputs.tf` - Outputs upon module application, including the creation of the inventory.yaml file
- `versions.tf` - The provider configuration file (to be filled out with your provider's details).

- `files/`
  - `cloud-config.yaml.tfpl` - template for cloud-init to install slurm master or nodes
  - `slurm.conf.tpl` - template for the slurm config file that is distributed over hosts via ansible
  - `slurmdbd.conf.tpl` - template for the slurmdb config file for master node
  - `cgroup.conf` - config file for slurm cgroups that is distributed across hosts via ansible
  - `gres.conf` - config file for slurm cgroups that is distributed across nodes via ansible
  - `inventory.tpl` - template for an inventory file created by Terraform creates
  - `*_topo_nccl*.xml` - correct topolgies for Infiniband devices distrubuted across nodes
  


## Configuring Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart).
- Add environment variables for Terraform authentication in Nebuis Cloud.

```
export YC_TOKEN=$(ncp iam create-token)
```


## Usage


To use this module in your Terraform environment, must first set  a Terraform configuration, such as the file `terraform.tfvars`, with the following example content:

```hcl
folder_id = "<folder_id>" # folder where you want to create your resources
sshkey = "<ssh_key>"
cluster_nodes_count = 4 # number of nodes
mysql_jobs_backend = false # Do you want to use mysql
platform_id = false  # gpu-h100 or gpu-h100-b
```

Once done, you can track the progress of cloud-init scripts:
```bash
ssh -i <ssh-key-path> slurm@<node-master-ip>
sudo tail -f /var/log/cloud-init-output.log
```