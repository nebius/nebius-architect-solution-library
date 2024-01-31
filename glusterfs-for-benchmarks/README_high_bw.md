# Glusterfs

Easiest way to make distributed HA storage based on GlusterFS

## Getting started

```bash
yc config profile activate <your profile>  
./env-yc-prod.sh
```

### Terraform

> !!! Change default storage number to 30 and increase resources (CPU/RAM) in variables

```bash
terraform init
terraform apply

# use output to access publically available first client
ssh storage@<IP_addr_of_client>
```

### GlusterFS installation

```bash
# client
sudo -i

dnf install epel-release -y
dnf install clustershell -y
echo 'ssh_options: -oStrictHostKeyChecking=no' >> /etc/clustershell/clush.conf

cat > /etc/clustershell/groups.conf <<'EOF'
[Main]
default: cluster
confdir: /etc/clustershell/groups.conf.d $CFGDIR/groups.conf.d
autodir: /etc/clustershell/groups.d $CFGDIR/groups.d
EOF

cat > /etc/clustershell/groups.d/cluster.yaml <<EOF
cluster:
    all: '@clients,@gluster'
    clients: 'client[01-30]'
    gluster: 'gluster[01-30]'
EOF

clush -w @all hostname # check and auto add fingerprints
clush -w @all dnf install centos-release-gluster -y
clush -w @all dnf --enablerepo=powertools install glusterfs-server -y
clush -w @gluster mkfs.xfs -f -i size=512 /dev/vdb
clush -w @gluster mkdir -p /bricks/brick1
clush -w @gluster "echo '/dev/vdb /bricks/brick1 xfs defaults 1 2' >> /etc/fstab"
clush -w @gluster "mount -a && mount"

clush -w @gluster systemctl enable glusterd
clush -w @gluster systemctl restart glusterd

clush -w gluster01 'for i in {2..9}; do gluster peer probe gluster0$i; done'
clush -w gluster01 'for i in {10..30}; do gluster peer probe gluster$i; done'
clush -w @gluster mkdir -p /bricks/brick1/vol0

# If there are many gluster nodes
export STRIPE_NODES=$(nodeset -S':/bricks/brick1/vol0 ' -e @gluster)
clush -w gluster01 gluster volume create stripe-volume ${STRIPE_NODES}:/bricks/brick1/vol0 

# Perf tuning
clush -w gluster01 gluster volume set stripe-volume client.event-threads 8
clush -w gluster01 gluster volume set stripe-volume server.event-threads 8
clush -w gluster01 gluster volume set stripe-volume cluster.shd-max-threads 8 # Cannot set cluster.shd-max-threads for a non-replicate volume
clush -w gluster01 gluster volume set stripe-volume performance.read-ahead-page-count 16
clush -w gluster01 gluster volume set stripe-volume performance.client-io-threads on
clush -w gluster01 gluster volume set stripe-volume performance.quick-read off
clush -w gluster01 gluster volume set stripe-volume performance.parallel-readdir on
clush -w gluster01 gluster volume set stripe-volume performance.io-thread-count 32
clush -w gluster01 gluster volume set stripe-volume performance.cache-size 1GB
# clush -w gluster01 gluster volume set stripe-volume performance.cache-invalidation: on # option : performance.cache-invalidation: does not exist
# clush -w gluster01 gluster volume set stripe-volume performance.md-cache-timeout: 600 # option : performance.md-cache-timeout: does not exist
# clush -w gluster01 gluster volume set stripe-volume performance.stat-prefetch: on # option : performance.stat-prefetch: does not exist
clush -w gluster01 gluster volume set stripe-volume server.allow-insecure on   
#clush -w gluster01 gluster volume set stripe-volume network.inode-lru-limit: 200000 # option : network.inode-lru-limit: does not exist
#clush -w gluster01 gluster volume set stripe-volume features.shard-block-size: 128MB # option : features.shard-block-size: does not exist
#clush -w gluster01 gluster volume set stripe-volume features.shard: on # option : features.shard: does not exist
#clush -w gluster01 gluster volume set stripe-volume features.cache-invalidation-timeout: 600 # option : features.cache-invalidation-timeout: does not exist
#clush -w gluster01 gluster volume set stripe-volume storage.fips-mode-rchecksum: on # option : storage.fips-mode-rchecksum: does not exist


# Start volume
clush -w gluster01  gluster volume start stripe-volume

# Check volumes status
clush -w gluster01  gluster volume status

# Mount volume to clients
clush -w @clients mount -t glusterfs gluster01:/stripe-volume /mnt/


# Create random file on first client
cat /dev/urandom | tr -dc '[:alnum:]' > /mnt/urandom.file

# Check hashsum on all clients
clush -w @clients sha256sum /mnt/urandom.file
# client01: 83a76155d74a67c59934fb984d025e6b787c8748345ef5317f096c8ba8ea7530  /mnt/urandom.file
# client02: 83a76155d74a67c59934fb984d025e6b787c8748345ef5317f096c8ba8ea7530  /mnt/urandom.file
# client03: 83a76155d74a67c59934fb984d025e6b787c8748345ef5317f096c8ba8ea7530  /mnt/urandom.file
```

### Benchmarking for Performance Configuration

#### IOR

```bash
# Start with latest step in GlusterFS Installation

# Install dependancies
clush -w @clients dnf install -y autoconf automake pkg-config m4 libtool git mpich mpich-devel make fio
cd /mnt/
git clone https://github.com/hpc/ior.git
cd ior
mkdir prefix
^C # exit current shell
sudo -i # enter again
module load mpi/mpich-x86_64
cd /mnt/ior

# Build & Install IOR Project
./bootstrap
./configure --disable-dependency-tracking  --prefix /mnt/ior/prefix
make 
make install
mkdir -p /mnt/benchmark/ior

# Run IOR 
export NODES=$(nodeset  -S',' -e @clients)
mpirun -hosts $NODES -ppn 16 /mnt/ior/prefix/bin/ior  -o /mnt/benchmark/ior/ior_file -t 1m -b 16m -s 16 -F # best BW: 1269.80 on write from 30 clients to 6 hosts
mpirun -hosts $NODES -ppn 16 /mnt/ior/prefix/bin/ior  -o /mnt/benchmark/ior/ior_file -t 1m -b 16m -s 16 -F -C # no read cache

[root@client01 ior]# mpirun -hosts $NODES -ppn 16 /mnt/ior/prefix/bin/ior  -o /mnt/benchmark/ior/ior_file -t 1m -b 16m -s 16 -F -C
IOR-4.1.0+dev: MPI Coordinated Test of Parallel I/O
Began               : Tue Dec 19 15:20:36 2023
Command line        : /mnt/ior/prefix/bin/ior -o /mnt/benchmark/ior/ior_file -t 1m -b 16m -s 16 -F -C
Machine             : Linux client01.eu-north1.internal
TestID              : 0
StartTime           : Tue Dec 19 15:20:37 2023
Path                : /mnt/benchmark/ior/ior_file.00000000
FS                  : 10.0 TiB   Used FS: 1.7%   Inodes: 1024.0 Mi   Used Inodes: 0.0%

Options:
api                 : POSIX
apiVersion          :
test filename       : /mnt/benchmark/ior/ior_file
access              : file-per-process
type                : independent
segments            : 16
ordering in a file  : sequential
ordering inter file : constant task offset
task offset         : 1
nodes               : 10
tasks               : 160
clients per node    : 16
memoryBuffer        : CPU
dataAccess          : CPU
GPUDirect           : 0
repetitions         : 1
xfersize            : 1 MiB
blocksize           : 16 MiB
aggregate filesize  : 40 GiB

Results:

access    bw(MiB/s)  IOPS       Latency(s)  block(KiB) xfer(KiB)  open(s)    wr/rd(s)   close(s)   total(s)   iter
------    ---------  ----       ----------  ---------- ---------  --------   --------   --------   --------   ----
write     1189.14    1196.85    1.38        16384      1024.00    1.45       34.22      33.07      34.44      0
read      1260.12    1261.46    0.437619    16384      1024.00    0.403822   32.47      28.97      32.50      0

```

#### FIO

```bash
# Maximize BW
fio --direct=1 --rw=write --bs=2M --ioengine=libaio --iodepth=4 --runtime=120 --time_based --runtime=30s --group_reporting --name=throughput-test-job --eta-newline=1 --size=100g --filename /bricks/brick1/vol0/fio/test.fio --numjobs=32 --end_fsync=1 --ramp_time=5 
# write raw
# WRITE: bw=83.4MiB/s (87.5MB/s), 83.4MiB/s-83.4MiB/s (87.5MB/s-87.5MB/s), io=2598MiB (2724MB), run=31134-31134msec

fio --direct=1 --rw=write --bs=2M --ioengine=libaio --iodepth=4 --runtime=120 --time_based --runtime=30s --group_reporting --name=throughput-test-job --eta-newline=1 --size=100g --filename /mnt/test.fio --numjobs=32 --end_fsync=1 --ramp_time=5 
# write glusterfs
# WRITE: bw=69.7MiB/s (73.0MB/s), 69.7MiB/s-69.7MiB/s (73.0MB/s-73.0MB/s), io=2188MiB (2294MB), run=31413-31413msec

fio --direct=1 --rw=read --bs=2M --ioengine=libaio --iodepth=4 --runtime=120 --time_based --runtime=30s --group_reporting --name=throughput-test-job --eta-newline=1 --size=100g --filename /mnt/test.fio --numjobs=32 --end_fsync=1 --ramp_time=5 
# glusterfs striped 
# READ: bw=620MiB/s (650MB/s), 620MiB/s-620MiB/s (650MB/s-650MB/s), io=18.2GiB (19.6GB), run=30099-30099msec
```
