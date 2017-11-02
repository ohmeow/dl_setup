#!/bin/bash

instance_name=${1:-fastai-part1v2}

# get instance Id for name
export instance_id=$(aws ec2 describe-instances --filters Name=tag:Name,Values=$instance_name --query 'Reservations[*].Instances[*].InstanceId') 

# stop instance
aws ec2 stop-instances --instance-ids $instance_id
