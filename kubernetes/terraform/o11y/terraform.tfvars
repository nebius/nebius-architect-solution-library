folder_id = "<put folder id here>"
o11y = {
  dcgm = {
    node_groups = {
      h100 = {                                     # name of node groups with GPUs
        gpus              = 2                      # GPUs per node
        instance_group_id = "a4h6ollme7ijmppk0stu" # instance group id (node hostname prefix before '-')
      }
    }
  }
}
