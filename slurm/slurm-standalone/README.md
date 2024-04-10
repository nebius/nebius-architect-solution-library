# Nebius slurm management Module

This Terraform module provisions a slurm cluster on Nebius Cloud. It creates a virtual machines for nodes and master configure them and may them ready to run. Additionally it installs plugins enroot and pyxis to make it possible to run container workloads

## Module Structure

The module includes the following files and directories:

- `main.tf` - The main Terraform configuration file for the module.
- `variables.tf` - Definitions of variables used within the module.
- `outputs.tf` - Outputs after the module has been applied. It creates inventory.yaml file
- `versions.tf` - The provider configuration file (to be filled in with your provider's details).

- `files/`
  - `cloud-config.yaml.tfpl` - template for cloud-init to install slurm master or ndoes
  - `slurm.conf.tpl` - template for slurm config file that is distributed over hosts via ansible
  - `slurmdbd.conf.tpl` - template for slurmdb config file for master node
  - `cgroup.conf` - config file for slurm cgroups that is distributed over hosts via ansible
  - `gres.conf` - config file for slurm cgroups that is distributed over nodes via ansible
  - `inventory.tpl` - template for invetory file that terraform creates
  - `*_topo_nccl*.xml` - correct topolgies for Infiniband devices that is distrubuted over nodes
  


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
sshkey = "<ssh_key>"
cluster_nodes_count = 4 # amount of nodes
mysql_jobs_backend = false  # Do you want to use mysql
platform_id = false  # gpu-h100 or gpu-h100-b
```

Then you can monitor the progress of cloud-init scripts:
```bash
ssh -i <ssh-key-path> slurm@<node-master-ip>
sudo tail -f /var/log/cloud-init-output.log
```
