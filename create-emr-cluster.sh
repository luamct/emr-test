#!/bin/bash

aws emr create-cluster \
     --name luam-spark-cluster \
     --release-label emr-5.30.0 \
     --instance-groups InstanceGroupType=MASTER,InstanceCount=1,InstanceType=m4.xlarge InstanceGroupType=CORE,InstanceCount=2,InstanceType=m4.xlarge \
     --service-role EMR_DefaultRole \
     --ec2-attributes InstanceProfile=EMR_EC2_DefaultRole,SubnetId=subnet-03940ce34e87ab44d,KeyName=spark-emr-test \
     --log-uri s3://spark-emr-test \
     --enable-debugging \
     --no-auto-terminate \
     --visible-to-all-users \
     --applications Name=Hadoop Name=Spark \
     --region us-east-1 \
     --profile dev
