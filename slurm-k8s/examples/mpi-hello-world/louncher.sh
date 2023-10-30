#!/bin/bash


#SBATCH -J MPItest          # Name the job as 'MPItest'
#SBATCH -o MPItest-%j.out   # Write the standard output to file named 'jMPItest-<job_number>.out'
#SBATCH -e MPItest-%j.err   # Write the standard error to file named 'jMPItest-<job_number>.err'
#SBATCH -t 0-12:00:00        # Run for a maximum time of 0 days, 12 hours, 00 mins, 00 secs
#SBATCH --nodes=2            # Request N nodes
#SBATCH --mail-type=ALL      # Send email notification at the start and end of the job

pwd                         # prints current working directory
date                        # prints the date and time

mpirun --allow-run-as-root python3 hello-world.py