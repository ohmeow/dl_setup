#!/bin/bash

instance_name=${1:-fastai-part1v2}

# get instance Id for name
export instance_id=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$instance_name --query 'Reservations[*].Instances[*].InstanceId') 

# start the instance
aws ec2 start-instances --instance-ids $instance_id
while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" = "pending"; do
  sleep 1; echo -n '.'
done; echo " $state"

# ssh into the instance
export instance_ip=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
ssh -i ~/.ssh/aws-key-or.pem ubuntu@$instance_ip -L 8888:127.0.0.1:8888
