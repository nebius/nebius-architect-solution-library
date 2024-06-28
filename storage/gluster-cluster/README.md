# About
This guide will walk you through the process of setting up distributed HA storage using GlusterFS. We will install the necessary Ubuntu VM nodes with GlusterFS software and create a Gluster volume across the node pool. 

By default, the script uses the stripe volume type, eliminating redundancy on the Gluster side. Therefore, it is recommended to use disks with redundancy on cloud side, such as SSD (network-ssd) or SSD-IO (network-ssd-io-m3) https://nebius.ai/docs/compute/concepts/disk

# What is GlusterFS?
GlusterFS is an open source, distributed file system that can scale up to several petabytes and support thousands of clients. It is a file system with a modular, stackable design and a unique no-metadata server architecture. This no-metadata server architecture ensures better performance, linear scalability, and reliability.

# Installation process

## Prepare environment
```bash
ncp config profile activate <your profile>  
source ./env-yc-prod.sh
```

## Change default parameters if required:

```bash
vi variables.tf
```

### Choose values for variables:

```
variable "storage_nodes"            description = "Number of storage nodes in cluster"
variable "disk_type"                description = "Type of GlusterFS disk"
variable "disk_size"                description = "Disk size GB"
variable "storage_cpu_count"        description = "Number of CPU in Storage Node"
variable "storage_memory_count"     description = "RAM (GB) size in Storage Node"
```

**NOTE:**

> Terraform will create new network environment for gluster cluster by default,  
> with new network/segment/routing table and NAT gateway to enable internet access from the cluster  
> (required by cloud-init scripts to install packages).

> To install GlusterFS nodes on the same network as the clients, import the network as follows:

```
terraform import nebius_vpc_network.default 'btc5atouoabbcir5abcd'
```
Enter the correct network ID

## Terraform rollout environment

```bash
terraform init
terraform plan
terraform apply
```

## Check installation

Check the serial port menu in the cloud console of the first gluster VM (gluster01)for the following lines,  which indicate that the gluster volume was successfully started:

```
[  187.339215] cloud-init[1051]: volume start: stripe-volume: success
…
[  OK  ] Finished Execute cloud user/final scripts.
[  OK  ] Reached target Cloud-init target.
```

You can also assign Public IP address to any gluster node and manually check the volume status:

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

# How to mount volume to clients VMs as a shared storage

Install the gluster-client software on the VM where mount will be done:

```bash
sudo apt-get -y update
sudo apt-get -y install glusterfs-client
```

and mount the volume manually:
```bash
mkdir -r /mnt/fs
mount -t glusterfs gluster01:/stripe-volume /mnt/fs
```

to automatically mount a volume add following config to /etc/fstab:

```bash
echo "gluster01:/stripe-volume /mnt/fs glusterfs defaults,_netdev 0 0" >> /etc/fstab
```

# Further reading

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