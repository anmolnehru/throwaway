#!/bin/bash

while read line 
do
#these need to be done in parallel on the slave nodes
ssh -i ~/data/brain_aws.pem ec2-user@$line 'bash -s' < local.sh &
#sleep 2 
done < "$1"
#wait??
