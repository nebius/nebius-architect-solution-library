# About
This guide will walk you through the process of setting up distributed HA storage using GlusterFS. We will install the necessary Ubuntu VM nodes with GlusterFS software and create a Gluster volume across the node pool. 

By default, the script uses the stripe volume type, eliminating redundancy on the Gluster side. Therefore, it is recommended to use disks with redundancy on cloud side, such as SSD (network-ssd) or SSD-IO (network-ssd-io-m3) https://nebius.ai/docs/compute/concepts/disk

# What is GlusterFS?
GlusterFS is an open source, distributed file system that can scale up to several petabytes and support thousands of clients. It is a file system with a modular, stackable design and a unique no-metadata server architecture. This no-metadata server architecture ensures better performance, linear scalability, and reliability.

## Key features of GlusterFS

**Scalability**: GlusterFS is designed to scale horizontally, allowing you to easily add more  storage nodes to the cluster as your storage requirements increase. It can handle petabytes of storage and multiple clients accessing data at the same time.

**Flexibility**: GlusterFS supports various storage types, including local disk, Network Attached Storage (NAS), Direct Attached Storage (DAS) and cloud storage, allowing you to create a unified storage pool from diverse storage resources.

**Redundancy and Fault Tolerance**: By implementing features such as replication and erasure coding (dispersed volumes), GlusterFS offers alternatives for ensuring data redundancy and fault tolerance.  These features ensure data availability and resilience against hardware failures.

**Distributed File System**: GlusterFS is a distributed file system, which means that files are distributed across multiple storage nodes, providing  high availability and load balancing.

**Unified Namespace**: GlusterFS offers clients a unified namespace regardless of the underlying storage infrastructure, which makes it easy to access and manage data across distributed storage nodes.

**Transparent Data Migration**: GlusterFS supports transparent data migration, allowing data to be moved between storage nodes without disrupting client access.

## GlusterFS is used in various scenarios, including:

**Big Data Analytics**: GlusterFS provides scalable storage for big data analytics platforms such as Hadoop and Spark, allowing organizations to efficiently store and process large amounts of data.

**Content Delivery**: GlusterFS can be used as a storage backend for content delivery networks (CDNs) and media streaming platforms, ensuring high availability and optimal performance when serving content to users.

**Virtualization and Cloud**: GlusterFS is used as a storage backend for virtualization platforms such as VMware and KVM, as well as cloud storage solutions, offering a scalable and flexible storage solution for virtual machines and cloud-based applications.

**High-Performance Computing (HPC)**: GlusterFS is used in HPC environments to provide scalable and parallel storage for compute-intensive workloads, such as scientific simulations and data analysis.

Overall, GlusterFS is a versatile distributed file system that meets the storage requirements of modern applications, providing scalability, flexibility, and reliability in a distributed storage environment.

## GlusterFS volume types 

GlusterFS supports a variety of volume  types, each offering unique characteristics and capabilities to meet various storage requirements. Let’s take a look atthe most commonly used GlusterFS volume types.

**Distributed volume (istribute):**

A distributed volume spreads data across multiple bricks (storage nodes) without replication or stripping.
Each file is stored entirely on a single brick, and files are distributed across bricks in a round-robin manner.
While this type of volume provides scalability by distributing data across multiple nodes, it does not guarantee redundancy or fault tolerance.

**Replicated volume (Replicate):**

A replicated volume replicates data across multiple bricks to ensure redundancy and fault tolerance.
Each file is stored on multiple bricks (replicas), guaranteeing data availability even if one brick fails.
Replicated volumes provide high availability and data reliability but may incur higher storage overhead due to data duplication.

**Striped volume (Stripe):**

A striped volume distributes data across multiple bricks for improved performance.
Each file is divided into fixed-size stripes, which are distributed across bricks in a round-robin manner.
Striped volumes enhance performance by distributing data across multiple nodes and disks. However, they do not provide redundancy or fault tolerance.

**Distributed replicated volume (Distribute-Replicate):**

A distributed replicated volume combines the characteristics of both distributed and replicated volumes.
Data is distributed across multiple bricks, with each piece of data replicated for redundancy.
y distributing data across multiple nodes and replicating it for redundancy, this type of volume provides both scalability and fault tolerance

**Distributed striped volume (Distribute-Stripe):**

A distributed striped volume combines the characteristics of distributed and striped volumes.
Data is distributed across multiple bricks, and each file is striped across multiple bricks for better performance.
By distributing and stripping data across multiple nodes, this type of volume improves both scalability and performance .

**Dispersed volume (Disperse):**

A dispersed volume, also known as erasure-coded volume, divides data into chunks and distributes them across multiple bricks together with parity chunks.
It provides fault tolerance and data protection by employing erasure coding techniques to reconstruct data from surviving chunks if brick failures occur.
Dispersed volumes offer storage efficiency and fault tolerance without incurring the storage overhead associated with replication.

 Each GlusterFS volume type has its own set of applications, with its own advantages and disadvantages. Choosing the appropriate volume type is determined by factors such as performance, data redundancy, and storage efficiency.

## Gluster fault tolerance and high availability for stripe volume

In  GlusterFS stripe volume, data is striped across multiple nodes without redundancy or replication. This means that each piece of data is split into smaller chunks (stripes) and distributed across the nodes in the stripe volume. As there is no redundancy or replication, the failure of any single node in a stripe volume may lead to data loss or unavailability for the affected files.

In a stripe volume:

- There is no inherent fault tolerance for node failures.
- If a node in a stripe volume fails, any data stored exclusively on that node becomes inaccessible until the node is restored or replaced.
- The loss of multiple nodes in a stripe volume can result in the loss of data stored on those nodes.

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

# Mount volume to clients

Install the gluster-client software on the client:

```bash
sudo apt-get -y update
sudo apt-get -y install glusterfs-client
```

and mount the volume:
```bash
mount -t glusterfs gluster01:/stripe-volume /mnt/
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