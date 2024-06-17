# Nebius slurm management Module

This Terraform module provisions a slurm cluster on Nebius Cloud. It creates a virtual machines for nodes and master configure them and may them ready to run. Additionally it installs plugins enroot and pyxis to make it possible to run container workloads

## Module Structure

The module includes the following files and directories:

- `main.tf` - The main Terraform configuration file for the module.
- `variables.tf` - Definitions of variables used within the module.
- `outputs.tf` - Outputs after the module has been applied. It creates inventory.yaml file
- `versions.tf` - The provider configuration file (to be filled in with your provider's details).
- `terraform.tfvars` - Variable values.

- `files/`
  - `cloud-config.yaml.tfpl` - template for cloud-init to install slurm master or worker nodes
  - `slurm.conf.tpl` - template for slurm config file that is distributed over hosts via ansible
  - `slurmdbd.conf.tpl` - template for slurmdb config file for master node
  - `cgroup.conf` - config file for slurm cgroups that is distributed over hosts via ansible
  - `gres.conf` - config file for slurm cgroups that is distributed over nodes via ansible
  - `inventory.tpl` - template for invetory file that terraform creates
  - `*_topo_nccl*.xml` - correct topolgies for Infiniband devices that is distrubuted over nodes

## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

## Prepare environment
```bash
ncp config profile activate <your-profile>
source ./environment.sh
```

or manually export variables:
```bash
export NCP_TOKEN=$(ncp iam create-token)
export NCP_CLOUD_ID=$(ncp config get cloud-id)
export NCP_FOLDER_ID=$(ncp config get folder-id)
```

## Usage

To use this module in your Terraform environment, you may run module and provide required variables in comman prompt
or you may define a Terraform configuration for example file `terraform.tfvars` with example content:

```hcl
folder_id = "<folder_id>" # folder where you want to create your resources
ssh_public_key = {
  key = "<ssh_public_key>", # public part of your SSH key used to connect to VMs in cluster later (has more priority than path)
  path = "<ssh_public_key_path>" # path to public part of your SSH key used to connect to VMs in cluster later
}
cluster_nodes_count = 4 # amount of worker nodes in slurm cluster
platform_id = gpu-h100  # gpu-h100 or gpu-h100-b
shared_fs_type = "<type>" should be one of "nfs", "gluster", "filestore" or null
```

Then you can monitor the progress of cloud-init scripts:
```bash
ssh slurm@<node-master-ip>
sudo tail -f /var/log/cloud-init-output.log
```

## Shared storage installation

You can install shared storage with three differnet types:

- managed Shared Filestorage from Nebius
- NFS VM with exported nfs storage will be mounted on all slurm worker nodes to /mnt/slurm
- GlusterFS cluster with shared Glusterfs volume mounted to all worke nodes in /mnt/slurm

to create shared storage, please edit `terraform.tfvars` file before running terraform script:

To enable creation of specific shared storage:
- variable "shared_fs_type" set to:
  - "filestore" to use shared managed FileStorage mounted on /mnt/slurm on every worker node
  - "nfs" to use shared NFS server mounted on /mnt/slurm on every worker node
  - "gluster" to use shared GlusterFS cluster mounted on /mnt/slurm on every worker node
  - `null` or remove it to use without shared storage
- variable "fs_size" - size of shared FileStorage or NFS size (number should be x930)

In case of Glusterfs you may change single node disk size
- variable "gluster_disk_size" - size of disk per each Gluster node (number should be x930)
- variable "gluster_nodes" - Amount of nodes in Gluster cluster (minimum 3)

## Postinstall steps

After all nodes rolled out. Please login by ssh to master slurm node:
```
ssh slurm@<master-node-public-ip> -i private-ssh-key
```

and run /tmp/setup_auth.sh script
```
sudo -i
bash /tmp/setup_auth.sh
```

after script run check the slurm cluster status:
```
sinfo -Nl
```

correct status should be like (STATE: idle):
```
NODELIST      NODES PARTITION       STATE CPUS    S:C:T MEMORY TMP_DISK WEIGHT AVAIL_FE REASON              
slurm-node-1      1    debug*        idle 160   160:1:1 129008        0      1   (null) none                
slurm-node-2      1    debug*        idle 160   160:1:1 129008        0      1   (null) none         
```
