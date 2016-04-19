#get the hash index/id of the current directory
ls | head -1 > index

#read the first line of index and store it in this variable
read -r a < index

echo "Job starting on $a" 

#legr stuff | compute
./shared/legr_dti_parallel $a/. shared/.

echo "Job completed on $a"

#copy back p_value to master
cp p_value.txt $a
scp -i LaunchEC2installMATLAB1023.pem $a ec2-user@52.70.48.243:~/.

