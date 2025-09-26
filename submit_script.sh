#!/bin/bash
#SBATCH -J cepa
#SBATCH -p general
#SBATCH --mail-type=ALL
#SBATCH --mail-user=abachhar@iu.edu
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=100
#SBATCH --time=50:00:00
#SBATCH --mem=96G
#SBATCH -A r01859

sleep 10
hostname
module reset
export PATH=$HOME/.juliaup/bin:$PATH
WORKDIR=$(pwd)
echo "Working directory: $WORKDIR"
echo $TMPDIR

julia_script="lih30_random_initialization_W_var_sample_rate_var.jl"
datafile="lih30.npy"

# Copy script and datafile once to TMPDIR
cp $WORKDIR/$julia_script $TMPDIR/
cp $WORKDIR/$datafile $TMPDIR/
cd $TMPDIR

export JULIAENV=N/u/abachhar/BigRed200/control-VQE/SimpleEvolve.jl

# Run the same script with different seeds in parallel
for seed in $(seq 0 99)
do
    OUTFILE="seed${seed}.out"
    echo "Starting seed $seed"
    touch $OUTFILE
    # sync output for monitoring
    while true; do
        rsync -av $OUTFILE $WORKDIR/$OUTFILE
        sleep 10
    done &
    # launch Julia in the background, passing seed as positional argument
    julia +1.11 --project=$JULIAENV -t 1 $julia_script $datafile $seed >& $OUTFILE &
done

wait
