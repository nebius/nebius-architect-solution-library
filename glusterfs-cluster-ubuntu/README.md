# About
Guide how to make distributed HA storage based on GlusterFS.
Will install required amount of Ubuntu VM nodes with glusterFS software installed.
Gluster volume will be created among nodes pool.

By default script will use stripe volume type, means no redundancy on gluster side, so you should use disks with redundancy on cloud side - like SSD (network-ssd) or SSD-IO (network-ssd-io-m3) https://nebius.ai/docs/compute/concepts/disk

# What is Glusterfs
GlusterFS is an open source, distributed file system capable of scaling to several petabytes and handling thousands of clients. It is a file system with a modular, stackable design, and a unique no-metadata server architecture. This no-metadata server architecture ensures better performance, linear scalability, and reliability.

## Here are some key features of GlusterFS:

**Scalability**: GlusterFS is designed to scale horizontally, allowing you to add additional storage nodes seamlessly to accommodate growing storage needs. It can scale to petabytes of storage and handle a large number of clients accessing data concurrently.

**Flexibility**: GlusterFS supports various storage types, including local disk, Network Attached Storage (NAS), Direct Attached Storage (DAS), and cloud storage, allowing you to create a unified storage pool from diverse storage resources.

**Redundancy and Fault Tolerance**: GlusterFS provides options for data redundancy and fault tolerance through features like replication and erasure coding (dispersed volumes). These features ensure data availability and resilience against hardware failures.

**Distributed File System**: GlusterFS is a distributed file system, meaning it distributes files across multiple storage nodes, allowing for high availability and load balancing.

**Unified Namespace**: GlusterFS presents a unified namespace to clients, regardless of the underlying storage infrastructure, making it easy to access and manage data across distributed storage nodes.

**Transparent Data Migration**: GlusterFS supports transparent data migration, allowing data to be moved between storage nodes seamlessly without disrupting client access.

## GlusterFS is commonly used in various scenarios, including:

**Big Data Analytics**: GlusterFS provides scalable storage for big data analytics platforms like Hadoop and Spark, allowing organizations to store and process large volumes of data efficiently.

**Content Delivery**: GlusterFS can be used as storage backend for content delivery networks (CDNs) and media streaming platforms, ensuring high availability and performance for serving content to users.

**Virtualization and Cloud**: GlusterFS is used as storage backend for virtualization platforms like VMware and KVM, as well as cloud storage solutions, providing scalable and flexible storage for virtual machines and cloud-based applications.

**High-Performance Computing (HPC)**: GlusterFS is used in HPC environments to provide scalable and parallel storage for compute-intensive workloads, such as scientific simulations and data analysis.

Overall, GlusterFS is a versatile distributed file system that addresses the storage needs of modern applications, providing scalability, flexibility, and reliability in a distributed storage environment.

## Glusterfs volume types available

GlusterFS supports several types of volumes, each offering different characteristics and capabilities to meet various storage requirements. Here are the commonly used GlusterFS volume types:

**Distributed Volume (Distribute):**

A distributed volume spreads data across multiple bricks (storage nodes) without replication or striping.
Each file is stored in its entirety on a single brick, and files are distributed across bricks in a round-robin fashion.
This type of volume provides scalability by distributing data across multiple nodes but does not offer redundancy or fault tolerance.

**Replicated Volume (Replicate):**

A replicated volume replicates data across multiple bricks for redundancy and fault tolerance.
Each file is stored on multiple bricks (replicas), ensuring data availability even if one brick fails.
Replicated volumes provide high availability and data reliability but may have higher storage overhead due to data duplication.

**Striped Volume (Stripe):**

A striped volume stripes data across multiple bricks for improved performance.
Each file is divided into fixed-size stripes, and these stripes are distributed across bricks in a round-robin fashion.
Striped volumes enhance performance by distributing data across multiple nodes and disks, but they do not provide redundancy or fault tolerance.

**Distributed Replicated Volume (Distribute-Replicate):**

A distributed replicated volume combines the characteristics of distributed and replicated volumes.
Data is distributed across multiple bricks, and each piece of data is replicated for redundancy.
This type of volume provides both scalability and fault tolerance by distributing data across multiple nodes and replicating it for redundancy.

**Distributed Striped Volume (Distribute-Stripe):**

A distributed striped volume combines the characteristics of distributed and striped volumes.
Data is distributed across multiple bricks, and each file is striped across multiple bricks for improved performance.
This type of volume provides both scalability and performance benefits by distributing and striping data across multiple nodes.

**Dispersed Volume (Disperse):**

A dispersed volume, also known as erasure-coded volume, splits data into chunks and distributes them across multiple bricks along with parity chunks.
It provides fault tolerance and data protection by using erasure coding techniques to reconstruct data from surviving chunks in the event of brick failures.
Dispersed volumes offer storage efficiency and fault tolerance without the storage overhead of replication.

Each GlusterFS volume type has its own use cases, advantages, and trade-offs. The choice of volume type depends on factors such as performance requirements, data redundancy needs, and storage efficiency considerations.

## Gluster fault tolerance and high availability for stripe volume

In a GlusterFS stripe volume, data is striped across multiple nodes without redundancy or replication. This means that each piece of data is split into smaller chunks (stripes) and distributed across the nodes in the stripe volume. Since there is no redundancy or replication, the loss of any single node in a stripe volume can result in data loss or unavailability for the affected files.

In a stripe volume:

- There is no inherent fault tolerance for node failures.
- If a node in a stripe volume fails, any data stored exclusively on that node becomes inaccessible until the node is restored or replaced.
- The loss of multiple nodes in a stripe volume can lead to the loss of data stored on those nodes.

# Installation procedure

## Prepare environment
```bash
ncp config profile activate <your profile>  
source ./env-yc-prod.sh
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
> with new network/segment/routing table and NAT gateway to internet access from cluster  
> (required by cloud-init scripts to install packages)

> If you want to install glusterfs nodes to the same natwork where the clients will sits,  
> you need to import the network as following:
```
terraform import nebius_vpc_network.default 'btc5atouoabbcir5abcd'
```
put here the correct network ID

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