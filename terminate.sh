#!/bin/sh
a=1
while read line 
do
#terminating all instances except master on CLI
aws ec2 terminate-instances --instance-ids "$line"
echo "Bringing down Machine #$a"
((a++))
done < "$1"
echo "We hope you enjoyed using this service"
