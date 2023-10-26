# slurm-cluster
This example creates a simple Slurm cluster running in k8s. It runs one master pod, jupyter lab pod, and three worker pods.


To run slurm cluster environment you must execute:

     $ cd deploy
     $ kubectl create namespace slurm
     $ kubectl apply -f . -n slurm

To stop it, you must:

     $ kubectl delete -f . -n slurm

## running simple paralel job from jupyter lab

Port forward jupyter service:

     $kubectl port-forward service/slurmjupyter 8888:8888 -n slurm

Open brower to localhost:8888
To check the state of the cluster, open the terminal icon and type:

     $ sinfo -N -l

Create a simple test.py script :

```
#!/usr/bin/env python3
  
import time
import os
import socket
from datetime import datetime as dt
if __name__ == '__main__':
    print('Process started {}'.format(dt.now()))
    print('NODE : {}'.format(socket.gethostname()))
    print('PID  : {}'.format(os.getpid()))
    print('Executing for 15 secs')
    time.sleep(15)
    print('Process finished {}\n'.format(dt.now()))
```

Create a job.sh script:

```
#!/bin/bash
#
#SBATCH --job-name=test
#SBATCH --output=result.out
#
#SBATCH --ntasks=6
#
sbcast -f test.py /tmp/test.py
srun python3 /tmp/test.py
```

Then, from the launcher page, click on Slurm Queue ->  Submit Job -> enter path /hpme/admin/job.sh
Hit refresh button to se the job queued.
After some time, you can see the results in the result.out file





