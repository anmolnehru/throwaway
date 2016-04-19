#get the hash index/id of the current directory
ls | head -1 > index

#read the first line of index and store it in this variable
read -r a < index

echo "Job starting on $a" 

#legr stuff | compute

#This is the real thing
./shared/legr_dti_parallel $a/. shared/.

#this is for the demo
#./shared/legr_dti $a/. shared/.
sleep 10
echo "Job completed on $a"

sleep 2

#copy back p_value to master
cp p_value.txt $a.txt

echo "Copying back p_value result from Machine #$a to Master"

scp -q -i LaunchEC2installMATLAB1023.pem $a.txt ec2-user@52.5.57.157:~/PVALUES/.

#check success of copying back somehow??
exit
