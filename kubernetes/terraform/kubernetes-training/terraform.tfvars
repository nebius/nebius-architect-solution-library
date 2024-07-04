folder_id       = "bjeq7qmo88loor6p1bac"
k8s_subnet_CIDR = ["192.168.11.0/24"]
gpu_nodes_count = 0
gpu_cluster = "fabric-4"
platform_id= "gpu-h100-c-llm"
network_id = "btckqjco34lr3c86ck1b"

shared_fs_type = "none"
gluster_disk_size = 930
gluster_disks_per_vm = 1
gluster_nodes= 10

#ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC66U0dlfhFgUptHTgrFIpfBvCSQofPP/jxbu8DL7ohtxCtYoA6N0kC8ZiMaUeW+84K3k2cRt53FqMG0vvgEFhuI/mk//BQXU7jbPKHhnEY5sO4QUaWRgIeo2zLRHrcSn5Uitw8309/64Ui0eVZvnMRE57ifOPLWEgHiSTD9nNMfb6vAdSFDj4vBOtVrcJxmBiXBQQ+0DQkbiRqI4UfW5YwQ1QToZ8cQSJrl4eX6oNH77fbid4DnTTHUulQztFUw3tQRR3zPkCVu6jazqHd2q/OL5sNdTwV9KOLJArxLkUDjXmVRZVsEY4oObL9a6m8epxOCufyub3it9UdNU/5ff7jj+1+7XYqoasnxrAC3Kqqg+jW3xx9MGDCuPBxJdagQgVBsVne5tT/WXoYMQ2EQ92JvrFS8B9Iw/xlvq5Wz+XwFHhvrKgOlwGJUKdf8RjJxU6Sx7m/fXzXv8INQAaGIQmZN3aQ4nUi+xL/lWdX/Zle5CE2947DY6UHWXrne9oSDGc= borispopovsr@i113070648"

o11y = {
  grafana = false
  loki    = false
  prometheus = {
    enabled = false
  }
  dcgm = {
    enabled = false
  }
}