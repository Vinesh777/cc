owens=vinesh@owens.osc.edu

weightType="$1";
seed="$2";
numberOfTries="$3";
batches="$4"
args="$1 $2 $3 $4";
i=$((seed+32))


jobid=`ssh ${owens} "singularity exec /users/PWSU0471/nehrbajo/python3.sif python3 manage.py ${weightType} $i ${numberOfTries} ${batches}; sleep 1; wait;"`

b=${jobid#*_}
c=${b%:*}
d=${b#* }
best_seed=$c
best_dist=$d
jobid=`ssh ${owens} "mv -f  best_${best_seed}.pickle bestIFound_0${weightType}.pickle"`

jobid1=`ssh ${owens} "rm -f best_*.pickle"`

a="import pickle; r=open('bestIFound_0${weightType}.pickle','rb'); d=pickle.load(r); l=pickle.load(r); print(d); print(l); r.close(); r=open('best_${best_seed}.txt', 'w'); r.write(str(d)+'\n'); r.write(str(l)+'\n'); r.close();"




echo ${best_seed}:${best_dist}>>outputaws$weightType.txt
