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
8. `top` | shows you a running measure of CPU and memory use for all the processes on the system you run it on
9. `htop` | see the utilization of a computer, by core, which is especially useful in parallelization
10. `strace -o myprogram.strace ./myprogram args` | monitors your program and logs everything it does.  Good for debugging, but is very noisy by default.
11. `scontrol update job=JOBID name=NEWNAME` | allows you to rename an running job


## ARC Submission scripts
<details>
  <summary> QChem example </summary>

```shell
#!/bin/bash
#SBATCH -N 1
#SBATCH -p normal_q
#SBATCH -t 72:00:00
#SBATCH --account=nmayhall_group
#SBATCH --cpus-per-task=12
##SBATCH --exclusive

module reset
module load CMake/3.16.4-intel-2019b
module load intel/2019b imkl/2019.5.281-iimpi-2019b
export qcSoft="/projects/nmayhall_lab/qchem5"
export QCPATH="$qcSoft/qchem.librassf-bloch-dev/"
export QC=$qcSoft/qchem.librassf-bloch-dev/
export QCAUX="/projects/nmayhall_lab/qchem5/qcaux/"
# export QCSCRATCH="$HOME/.qchem_scratch"
export QCSCRATCH=$TMPDIR/tinkercliff_qchem
export PATH=$PATH:$QC/bin:$QC/bin/perl


echo "Usage: sbatch submit.sh {input file} {data file} {data file}"

export INFILE=$1
export OUTFILE="${INFILE}.out"
export WORKDIR=$(pwd)

echo $INFILE
echo $OUTFILE
echo $WORKDIR
echo $TMPDIR
echo $QCSCRATCH

cp $INFILE $TMPDIR/
if [ "$2" ]
  then
    cp $2 $TMPDIR/
fi

cd $TMPDIR

#Start an rsync command which runs in the background and keeps a local version of the output file up to date
touch $OUTFILE
while true; do rsync -av $OUTFILE $WORKDIR/"${INFILE}.${SLURM_JOB_ID}.out"; sleep 60; done &

qchem -nt 12 $INFILE $OUTFILE scr

rsync -av $OUTFILE $WORKDIR/"${INFILE}.${SLURM_JOB_ID}.out"

#mv "$WORKDIR/"${INFILE}.${SLURM_JOB_ID}.out" "$WORKDIR/"${INFILE}.out"

mkdir $WORKDIR/"${INFILE}.${SLURM_JOB_ID}.scr"

cp -r . $WORKDIR/"${INFILE}.${SLURM_JOB_ID}.scr/"
#cp -r $QCSCRATCH/scr $WORKDIR/"${INFILE}.${SLURM_JOB_ID}.scr/"

exit;
```
  
</details>

<details>
  <summary> Julia example </summary>

```shell
#!/bin/bash

###SBATCH -J
#SBATCH -N 1
#SBATCH -p normal_q
#SBATCH --cpus-per-task=20
#SBATCH --mem=200G
#SBATCH -t 72:00:00
#SBATCH --account=nmayhall_group
##SBATCH --account=nmayhall_group-paid

export NTHREAD=20
export JULIAENV=/home/nmayhall/tinkercliffs/code/FermiCG/


# allow time to load modules, this takes time sometimes for some reason
sleep 10

hostname

module reset
module load Python/3.8.6-GCCcore-10.2.0
module load Julia/1.7.2-linux-x86_64

echo "Usage: sbatch submit.sh {input file} {data file} {data file}"

# set these to 1 if you are using julia threads heavily to avoid oversubscription
export MKL_NUM_THREADS=1
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1

export INFILE=$1
export OUTFILE="${INFILE}.out"
export WORKDIR=$(pwd)

echo $INFILE
echo $OUTFILE
echo $WORKDIR
echo $TMPDIR

cp $INFILE $TMPDIR/
if [ "$2" ]
then
	cp $2 $TMPDIR/
fi
if [ "$3" ]
then
	cp $3 $TMPDIR/
fi
cd $TMPDIR


#Start an rsync command which runs in the background and keeps a local version of the output file up to date
touch $OUTFILE
while true; do rsync -av $OUTFILE $WORKDIR/"${INFILE}.${SLURM_JOB_ID}.out"; sleep 60; done &


julia --project=$JULIAENV -t $NTHREAD $INFILE >& $OUTFILE

cp $OUTFILE $WORKDIR/"${INFILE}.out"
rm $WORKDIR/"${INFILE}.${SLURM_JOB_ID}.out"

mkdir $WORKDIR/"${INFILE}.scr"
cp -r * $WORKDIR/"${INFILE}.scr"

rm -r *

exit
```
</details>
