#!/usr/bin/python3
# Name: Vinesh Vangapandu 
# wNumber: w153vxv
# Project name: proj03
# Assigned: Sept 20
# Due date: Oct 8
# Tested on: fry

fry=w153vxv@fry.cs.wright.edu
owens=vinesh@owens.osc.edu
aws=ubuntu@54.162.177.47
awskey=~/.ssh/labsuser.pem



weight="$1"
seed="$2"
numtrys="$3"
batches="$4"

scp  ${fry}:/home/w006jwn/proj03data/* . 2> /dev/null

## copy from owens to fry and aws
createfolder=`ssh ${owens} mkdir -p workflow;`
copy=`scp ./* ${owens}:~/workflow/. & wait;`

createfolder=`ssh -i $awsKey ${aws} mkdir -p workflow;`
copy=`scp -i $awsKey ./* ${aws}:~/workflow/. & wait;`

for (( i=0; i<$(batches); i++ ))
do
   #run templates
   

   fryJOBId=`ssh  ${fry} "sbatch  /home/w153vxv/workflow/fryTemplate.sbatch ${weightType} ${pickleFile} $((seed)) ${numberOfTries}; sleep 2; wait;"`
owensJobId=`ssh  ${owens} "sbatch  /users/PWSU0484/vinesh/workflow/owensTemplate.sbatch ${weightType} ${pickleFile} $((seed+16)) ${numberOfTries}; sleep 2; wait;"`
aws_best=`ssh -i $awsKey ${aws} "cd workflow; sh  awsTemplate.sh  ${weightType} ${pickleFile} $((seed+32)) ${numberOfTries}; sleep 2; wait;"`


owenId=$( cut -d' ' -f4 <<<${owensJobId} )
fryId=$( cut -d' ' -f4 <<<${fryJOBId} )
echo $fryId
echo `pwd`
fryOutput="result-04_${fryId}.txt"
owensOutput="result-04_${owenId}.txt"
awsBest=$aws_best
echo $benderOutput

#reading result file seed:Distance within
#benderBest=`cat $benderOutput`
fryBest=`ssh  ${fry} "cat ${fryOutput}"`
echo "fry Out"
no_of_word_count=`ssh ${owens} "wc -l ${owensOutput}"`
owensBest=`ssh  ${owens} "sed '1,$((no_of_word_count-1))d' ${owensOutput}"`
echo "owensss out"


echo $awsBest
echo $owensBest
echo $fryBest


#cut seed and distance from each system
frySeed=${fryBest%:*}
fryDistance=${fryBest#*:}
owensSeed=${owensBest%:*}
owensDistance=${owensBest#*:}
awsSeed=${awsBest%:*}
awsDistance=${awsBest#*:}

#consider bender is best then compare
bestSeed=$owensSeed
bestDistance=$owensDistance





if [ ${fryDistance} -lt ${bestDistance} ]
then

bestSeed=${frySeed}
bestDistance=${fryDistance}
cp=`scp ${owens}:~/workflow/${pickleFile} . & wait;`
echo "copy owens bes_.pick"
elif [ ${awsDistance} -lt ${bestDistance} ]
then

bestSeed=$awsSeed
bestDistance=$awsDistance
cp=`scp -i $awsKey ${aws}:~/workflow/${pickleFile} . & wait;`
echo "copy aws pikl"

fi

cp=`mv -f ~/${pickleFile} bestIFoundSoFar${i}.pickle & wait;`

sleep 3;
pickleFile="bestIFoundSoFar${i}.pickle"




cpToAws=`scp -i $awsKey ~/workflow/${pickleFile} ${aws}:~/workflow/. & wait;`
cpToOwens=`scp  ~/${pickleFile} ${owens}:~/workflow/. & wait;`
cpToFry=`scp  ~/${pickleFile} ${fry}:~/workflow/. & wait;`








echo $seed > lastSeed.txt
echo $weightType > lastWeightType.txt
echo bestIFoundSoFar${i}.pickle > lastBestIFoundSoFar.txt
echo $numberOfTries > lastNumberOfTries.txt
echo $numberOfBatches > lastNumberOfBatches.txt
echo $(($i+1)) > Loop.txt
mv bestIFoundSoFar${i}.pickle savedState.pickle
echo "Terminated Successfully"
exit 0


echo $bestDistance

## end of FOR loop

sl=`ssh -i ~/.ssh/bender_owens_key ${owens} "rm update03.sh 2> /dev/null;
if [ ! -f 'update03.sh' ] 
then
 ln -s /users/PWSU0471/nehrbajo/proj03data/update03.sh ~/update03.sh; 
fi;"`

if [ ${bestSeed} -eq ${frySeed} ]
then
#remove from owens rm best_${bestSeed}.txt 2> /dev/null
remove=`ssh  ${owens} "rm best_${bestSeed}.txt 2> /dev/null & wait;"`
send=`scp best_"${bestSeed}".txt ${owens}:~/ & wait;`
jobid1=`ssh  ${owens} "bash update03.sh ${weightType} best_${bestSeed}.txt;"`
if [ -f outputFile.txt ]
then
re=`cat outputFile.txt`
echo $re
fi

echo $jobid1

elif [ ${bestSeed} -eq ${owensSeed} ] 
then
jobid1=`ssh  ${owens} "bash update03.sh ${weightType} ~/workflow/best_${bestSeed}.txt;"`
if [ -f outputFile.txt ]
then 
re=`cat outputFile.txt`
echo $re
fi
echo $jobid1
else
rm best_${bestSeed}.txt 2> /dev/null
copy=`scp -i ~/.ssh/labsuser.pem ${aws}:~/workflow/best_${bestSeed}.txt . & wait;`
remove=`ssh ${owens} "rm best_${bestSeed}.txt 2> /dev/null & wait;"`
past=`scp best_"${bestSeed}".txt ${owens}:~/`
jobid1=`ssh  ${owens} "bash update03.sh ${weightType} best_${bestSeed}.txt;"`
if [ -f outputFile.txt ]
then 
re=`cat outputFile.txt`

echo $re
fi
echo $jobid1


fi


done


