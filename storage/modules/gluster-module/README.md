# About
Guide how to make distributed HA storage based on GlusterFS.
Will install required amount of Ubuntu VM nodes with glusterFS software installed.
Gluster volume will be created among nodes pool.

By default script will use stripe volume type, means no redundancy on gluster side, so you should use disks with redundancy on cloud side - like SSD (network-ssd) or SSD-IO (network-ssd-io-m3) https://nebius.ai/docs/compute/concepts/disk

# What is Glusterfs
GlusterFS is an open source, distributed file system capable of scaling to several petabytes and handling thousands of clients. It is a file system with a modular, stackable design, and a unique no-metadata server architecture. This no-metadata server architecture ensures better performance, linear scalability, and reliability.

!!! Note: please do not change the default gluster node names: gluster01..glusterXX !!!

# Installation procedure

## Prepare environment
```bash
ncp config profile activate <your profile>  
source ./environment.sh
```

or manually export variables:

```bash
export NCP_TOKEN=$(ncp iam create-token)
export NCP_CLOUD_ID=$(ncp config get cloud-id)
export NCP_FOLDER_ID=$(ncp config get folder-id)
```

## Change default parameters if required:

```bash
vi variables.tf
```

### Choose values for variables

```
variable "network_name"             description = "Name of the network"
variable "subnet_name"              description = "Name of subnet"
variable "storage_node_per_zone"    description = "Number of storage nodes per zone"
variable "disk_type"                description = "Type of GlusterFS disk"
variable "disk_size"                description = "Disk size GB"
variable "storage_cpu_count"        description = "Number of CPU in Storage Node"
variable "storage_memory_count"     description = "RAM (GB) size in Storage Node"
variable "local_pubkey_path"        description = "Local public key to access the VMs"
```

**NOTE:**

> by default terraform will create new network environment for gluster cluster,  
> with new network/segment/routing table and NAT gateway to internet access from cluster nodes
> (required by cloud-init scripts to install packages)

> If you want to install glusterfs nodes to the same natwork where the clients will sits,  
> you need to import the network as following:
```
terraform import nebius_vpc_network.default '<your_network_id>'
```
put here the correct network ID, and script will add new network segment, routing table and NAT gateway to this segment.
Clients from the same network (other segments) will have routing to the gluster segment.

## Terraform rollout environment

```bash
terraform init
terraform plan
terraform apply
```

## Check installation

Check serial port menu in cloud console of first gluster VM (gluster01)
and look for the following lines, means gluster volume started sucessfully:

```
[  187.339215] cloud-init[1051]: volume start: stripe-volume: success
…
[  OK  ] Finished Execute cloud user/final scripts.
[  OK  ] Reached target Cloud-init target.
```

You may also assign Public IP address to any gluster node and check volume status manually:

```bash
ssh storage@<node-public-ip> -i <private-ssh-key>
gluster volume status
```
output should show all nodes in Online: Y status
```
gluster01: Status of volume: stripe-volume
gluster01: Gluster process                             TCP Port  RDMA Port  Online  Pid
gluster01: ------------------------------------------------------------------------------
gluster01: Brick gluster01:/bricks/brick1/vol0         55775     0          Y       32577
gluster01: Brick gluster02:/bricks/brick1/vol0         50780     0          Y       31789
gluster01: Brick gluster03:/bricks/brick1/vol0         59336     0          Y       31810
...
```

# Mount volume to clients

On client you will need to install gluster-client software:

```bash
sudo apt-get -y update
sudo apt-get -y install glusterfs-client
```

and mount the volume:
```bash
mount -t glusterfs gluster01:/stripe-volume /mnt/
```

To keep the volume mounted after restarts, add it to /etc/fstab:

```bash
mkdir /mnt/gfs
echo "gluster01:/stripe-volume /mnt/gfs glusterfs defaults,_netdev 0 0" >> /etc/fstab
```

# More to read

- GlusterFS Documentation: https://glusterdocs.readthedocs.io/en/latest/
- GlusterFS Architecture: https://glusterdocs.readthedocs.io/en/latest/Quick-Start-Guide/Architecture/

# Benchmarks

## 10x10 SSD-IO x10 clients c4m8 x10 storage c8m8 
```
access    bw(MiB/s)  IOPS
------    ---------  ----
write     2062.66    2064.48
read      1917.90    1919.93
```
## 10x10 Network-SSD x10 clients c4m8 x10 storage c8m8 
```
access    bw(MiB/s)  IOPS
------    ---------  ----
write     1996.43    1998.58
read      2026.12    2029.60
```
## 10x10 clients: x10 c40m120 | storage: x10 c8m8 + 1TB Network-SSD
```
access    bw(MiB/s)  IOPS
------    ---------  ----
write     3190.72    3191.42
read      5640       5641
```
## 30x30 clients x30 c40m120 | storage: x30 c8m8 + 1TB Network-SSD
```
access    bw(MiB/s)  IOPS
------    ---------  ----
write     10316      10319
read      14001      14003
```