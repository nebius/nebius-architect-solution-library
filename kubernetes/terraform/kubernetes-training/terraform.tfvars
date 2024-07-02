folder_id       = "<folder-id>"
k8s_subnet_CIDR = ["192.168.10.0/24"]
gpu_nodes_count = 2
gpu_cluster = "fabric-4"
platform_id= "gpu-h100-c-llm"


shared_fs_type = "gluster"
gluster_disk_size = 930
gluster_disks_per_vm = 1
gluster_nodes= 10

ssh_public_key = ""