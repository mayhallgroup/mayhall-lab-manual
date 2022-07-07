# Tips for using ARC

Here we collect tips and tricks for running calculations on ARC

## List of useful commands
1. `squeue -u nmayhall` | replace `nmayhall` with your username to see your own jobs
2. `quota` | Check the amount of hrs and diskspace you have left
3. `sbatch script.sh` | replace `script.sh` to your job name to submit the job to the Slurm scheduler
4. `scancel <JobId>` | cancels the incomplete job associated with the JobId stated
5. `sacct -j <JobId>` | provides information on the requested job.  There are numerous formatting flags that can be used, all of which can be seen by `sacct -e`
6. `scontrol show job <JobId>` | provides detailed information about the stated **completed** job
7. `seff <JobId>` | provides an efficiency report for the stated **completed** job 
