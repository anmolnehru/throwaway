#! /bin/sh
#Author -  UW-Madison

#creates key file called brain_aws.pem for ssh sessions # Only needed once for the 1st run
#aws ec2 create-key-pair --key-name brain_aws --query 'KeyMaterial' --output text > brain_aws.pem

#changes permissions || Imp step, don't remove
#chmod 400 brain_aws.pem

echo ""
echo ""
echo "--------------------------------------------"
echo "--------------------------------------------"
echo ""
echo "       Welcome to the BRAIN-AWS system"
echo "© 2015-16  UW-Madison. All rights reserved"
echo ""
echo "--------------------------------------------"
echo "--------------------------------------------"
echo ""



#**********************MATLAB PORTION IN COMMAND LINE**********************#
#invokes non gui based matlab and runs step1(aggregator into a single .MAT file
matlab -nosplash -nodesktop -r run step1.m

#executes step2
run(step2)

#finish
exit

echo ""
###spawns 19 instances(limit of 20, inclusive) of type c4.8xlarge with security brain_aws file & pipes output to servers.json
##update
#spawns 50 instances of c4.8xlarge(AWS approved limit increase)

#************************Big-data portion of the project begins*********************#


#set the total number of servers
count_servers=50
#specify server type
server_type=c4.8xlarge

#spawn master-1 number of servers
aws ec2 run-instances --image-id ami-60b6c60a --security-group-ids sg-11515077  --count $count_servers --instance-type $server_type --key-name brain_aws > silence_start_log.txt

./spawn_loader.sh
echo "--------------------------------------------"

#change sec perms of ssh files
sudo chmod 600 ~/.ssh/config_copy
sudo chmod 600 ~/.ssh/config


#IMPLEMENT A PAUSE TO WAIT UNTIL INSTANCES ARE BOOTED UP
#sys.pause(10);
echo "--------------------------------------------"
echo ""
#t=120
#while [t -gt 0]
#waits for 1.5 mins
./time_loader.sh
#sleep 2m #wait 2 mins

#describe the instances and pull the public ips(non elastic) || maybe better to do in prev step only??
aws ec2 describe-instances > servers.txt
grep "PublicIpAddress" servers.txt > public_ip.txt
#should store list of ips in public_ip.txt ##done


#interesting nice script to properly format the file
vim -S vim.trim public_ip.txt

#remove the master ip address from this list
#look into making this dynamic as well - could be interesting
sed '/52.5.57.157/d' public_ip.txt > final_public_ip.txt

#get list of instance ids handy for emergency termination if necessary
aws ec2 describe-instances | grep "InstanceId" > ids.txt

#trim the file to the proper format with vim.trim.instances, same file works !!magic
vim -S vim.trim ids.txt

#now remove the master id from here amnd write back
sed '/i-7d7c66c3/d' ids.txt > final_ids.txt
#Note, consider making the above step may be made more generic


#parse servers.json? (python)? to obtain list of private ips of children
#ip_list=parse(servers.json) #python call

rm -r ~/PVALUES
mkdir ~/PVALUES
#STATE RUNNING
#servers running state

#starts the 50th job in the backgroud
./shared/legr_dti 50/. shared/. &
job_pid=$!

#pulls up the list of ips and connects to them seamlessly
#and copies over various portions of data
./execute_command_from_ipfile.sh final_public_ip.txt
#better to be in blocking mode for safety, anyway not too long

echo "Setting up network authentication rules on slaves..."
echo ""
sleep 3
echo "Authentication setup succesfully"
echo ""
sleep 3

#executes individual queries (p_value computations) on slaves parallely
./parallel_execute_slaves.sh final_public_ip.txt

echo ""
echo "Processing...."
sleep 2
echo ""

#wait for the master's legr_process to complete
wait $job_pid
echo ""
echo "Processing...."
sleep 2
echo ""

#move the local file to the final resting place
mv p_value.txt ~/PVALUES/50.txt



#Upon this job completion messages will come in and all pvalues should get accumulated
#begin verficiation of p_values

#######
########build in redundancy here

#will be interesting to see the various cases
#if(failure in an index) -- respawn that directory on a new instance

#job mostly copmpleted, will wait for the p_value texts to come flooding in
#stitch them together?

echo""
echo""
echo""
#verify(p_values)
./count.sh 
#add logic to check for corrupt values and respawn job if needed

#concatenate all the part files to the final file
#it goes to FINAL_P_VALUE/final_p_value.txt
sh ~/data/run_50/txt_rnm_concat.sh

echo "Data verified. P_Values aggregated"
echo ""

#begin instance termination 
#Iterate through the ids and terminate instances
./terminate.sh  final_ids.txt > silence_terminate_log.txt &
./terminate_loader.sh
sleep 3

echo ""

#add logic to check if this is indeed done
#aws ec2 describe-instances | grep "InstanceId" > ids_check.txt
#
##trim the file to the proper format with vim.trim.instances, same file works !!magic
#
#vim -S vim.trim ids_check.txt
#check only single line exists
#working on this
#count=$(wc -l ids_check.txt)
#if [$count -ne 1]
#fail
#echo "Failed to terminate all worker systems ---------> FAIL-ERROR FULL TERMINATION. Please contact Authors"
#else
#success
#echo "All worker systems terminated ---------> Success"
#cleanup of files
#fi


sleep 3
echo "Cleaning up temporary files..."
sleep 3
cd ~/data/run_50
mv *.txt ../junk/
T="$(date +%s)"
#mv ~/PVALUES ~/PVALUES_$T
sleep 3

echo "Done"
echo ""
echo "Please remember to COPY YOUR DATA BACK TO YOUR LOCAL MACHINE"
sleep 3
echo ""
echo ""


echo "--------------------------------------------"
echo ""
echo "© 2015-16 UW-Madison. All rights reserved"
echo ""
echo "--------------------------------------------"

#Done, sit back and relax :)
#End
