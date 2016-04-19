#!/bin/bash
a=1
while read line 
do
        #The variable input data folder
	scp -q -i ~/data/brain_aws.pem -r $a ec2-user@$line:~/
	#The security file for the copy back
	scp -q -i ~/data/brain_aws.pem  ~/data/LaunchEC2installMATLAB1023.pem ec2-user@$line:~/
	#The shared data folder common to all
	scp -q -i ~/data/brain_aws.pem -r shared ec2-user@$line:~/
	#The below line is not necessary, as we are executing commands remotely
	#scp -q -i ~/data/brain_aws.pem    remote.sh ec2-user@$line:~/
	#Making the slaves free of host checking for the copyback ;), it's secure and only for this particular master
	scp -q -i ~/data/brain_aws.pem ~/.ssh/config_copy ec2-user@$line:~/.ssh/config
	
	#Look into implementing this feature
	#scp -q myfile user@host.com:. && echo success!
	echo "Completed transfer to Machine #$a @ $line---------->  Success"
	((a++))
done < "$1"

