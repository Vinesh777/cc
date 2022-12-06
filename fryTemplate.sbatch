#!/usr/bin/bash
#SBATCH --account=PWSU0493
#SBATCH -N 1
#SBATCH --tasks-per-node=16
#SBATCH --job-name=sbatch-fry
#SBATCH --output=result-03_%A.txt



weightType="$1";
seed="$2";
numberOfTries="$3";
batches="$4"
args="$1 $2 $3 $4";

jobid=`singularity exec /home/w006jwn/python3.sif python3 manage.py ${weightType} $seed ${numberOfTries} ${batches};`

# c is seed numer, d is distance for the rout
b=${jobid#*_}
c=${b%:*}
d=${b#* }
best_seed=$c
best_dist=$d

for i in $(seq $((seed+1)) $(($seed+15))); do
jobid=`singularity exec /home/w006jwn/python3.sif python3 manage.py ${weightType} $i ${numberOfTries} ${batches}; sleep 1; wait;`

b=${jobid#*_}
c=${b%:*}
d=${b#* }

if [ $d -lt $best_dist ]
then
best_dist=$d
best_seed=$c
fi

done

jobid=`mv -f best_${best_seed}.pickle bestIFound_0${weightType}.pickle & wait;`

jobid1=`rm -f best_*.pickle;`

a="import pickle; r=open('bestIFound_0${weightType}.pickle','rb'); d=pickle.load(r); l=pickle.load(r); print(d); print(l); r.close(); r=open('best_${best_seed}.txt', 'w'); r.write(str(d)+'\n'); r.write(str(l)+'\n'); r.close();"


echo ${best_seed}:${best_dist}
