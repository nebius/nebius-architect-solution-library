# JuiceFS

Guide how to make distributed storage based on JuiceFS

## Getting started

```bash
yc config profile activate <your profile>  
. ./env-nebius.sh
```

### Terraform

```bash
terraform init
vi variables.tf
# choose default values for variables
terraform apply

# use output to access publically available first client
ssh juicefs@<IP_addr_of_client>
```

### JuiceFS installation

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
    all: '@clients'
    clients: 'client[01-10]'
EOF

clush -w @all hostname # check and auto add fingerprints
# optionally if above command not working: ssh juicefs@client01

# Use tmpfs as a cache. Remount with bigger size
clush -w @all mount -o size=32000M -o remount /dev/shm

clush -w @clients 'curl -sSL https://d.juicefs.com/install | sh -'
clush -w @clients mv /usr/local/bin/juicefs /usr/local/sbin/

export YC_ACCESS_KEY_ID=<KEY>
export YC_SECRET_KEY=<SECRETKEY>
export YC_BUCKET_NAME=<NAME>
export YC_REDIS_CONNECT_URL=redis://:<pwd>@<fqdn>:6379/1

juicefs format \
    --storage s3 \
    --bucket https://${YC_BUCKET_NAME}.storage.ai.nebius.cloud \
    --access-key ${YC_ACCESS_KEY_ID} \
    --secret-key ${YC_SECRET_KEY} \
    ${YC_REDIS_CONNECT_URL} myjfs

clush -w @clients juicefs mount --cache-dir /dev/shm/jfscache ${YC_REDIS_CONNECT_URL} /mnt/jfs -d

# Check
cat /dev/urandom | tr -dc '[:alnum:]' > /mnt/jfs/urandom.file
clush -w @clients sha256sum /mnt/jfs/urandom.file

```

### Benchmarking for Performance Configuration

#### IOR

```bash
# Start with latest step in GlusterFS Installation

# Install dependancies
export JFS_MOUNT_DIR=/mnt/jfs
clush -w @clients dnf install -y autoconf automake pkg-config m4 libtool git mpich mpich-devel make fio
cd $JFS_MOUNT_DIR
git clone https://github.com/hpc/ior.git
cd ior
mkdir prefix
^C # exit current shell
sudo -i # enter again
module load mpi/mpich-x86_64
export JFS_MOUNT_DIR=/mnt/jfs
cd $JFS_MOUNT_DIR/ior

# Build & Install IOR Project
./bootstrap
./configure --disable-dependency-tracking  --prefix $JFS_MOUNT_DIR/ior/prefix
make 
make install
mkdir -p $JFS_MOUNT_DIR/benchmark/ior

# Run IOR 
export NODES=$(nodeset  -S',' -e @clients)
mpirun -hosts $NODES -ppn $(nproc) $JFS_MOUNT_DIR/ior/prefix/bin/ior  -o $JFS_MOUNT_DIR/benchmark/ior/ior_file -t 64k -b 128k -s 12800 -F -C -e
mpirun -hosts $NODES -ppn $(nproc) $JFS_MOUNT_DIR/ior/prefix/bin/ior  -o $JFS_MOUNT_DIR/benchmark/ior/ior_file -t 64k -b 16m -s 16 -F -C # no read cache

access    bw(MiB/s)  IOPS       Latency(s)  block(KiB) xfer(KiB)  open(s)    wr/rd(s)   close(s)   total(s)   iter
------    ---------  ----       ----------  ---------- ---------  --------   --------   --------   --------   ----
write     617.11     9874       47.68       128.00     64.00      0.394270   103.71     17.90      103.71     0
read      2531.72    40509      11.83       128.00     64.00      0.110531   25.28      4.05       25.28      0

access    bw(MiB/s)  IOPS       Latency(s)  block(KiB) xfer(KiB)  open(s)    wr/rd(s)   close(s)   total(s)   iter
------    ---------  ----       ----------  ---------- ---------  --------   --------   --------   --------   ----
write     515.12     10603      0.051229    16384      64.00      0.269630   15.45      9.18       19.88      0
read      2934.71    46968      0.010072    16384      64.00      0.040733   3.49       1.12       3.49       0

```

#### FIO

```bash
# Maximize BW
fio --direct=1 --rw=write --bs=2M --ioengine=libaio --iodepth=4 --runtime=120 --time_based --runtime=30s --group_reporting --name=throughput-test-job --eta-newline=1 --size=100g --filename /bricks/brick1/vol0/fio/test.fio --numjobs=32 --end_fsync=1 --ramp_time=5 # raw mounted hdd xfs disk ~ 240 MB/s (max of disk)

fio --direct=1 --rw=write --bs=2M --ioengine=libaio --iodepth=4 --runtime=120 --time_based --runtime=30s --group_reporting --name=throughput-test-job --eta-newline=1 --size=100g --filename /mnt/test.fio --numjobs=32 --end_fsync=1 --ramp_time=5 # glusterfs regional-striped ~ bw=113MiB/s
# perhaps it is latency between DC

fio --direct=1 --rw=read --bs=2M --ioengine=libaio --iodepth=4 --runtime=120 --time_based --runtime=30s --group_reporting --name=throughput-test-job --eta-newline=1 --size=100g --filename /mnt/test.fio --numjobs=32 --end_fsync=1 --ramp_time=5 # glusterfs regional-striped ~ bw=99.0MiB/s
```
