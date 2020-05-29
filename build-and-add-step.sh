#!/bin/bash

#set -o xtrace
set -e

function join_by {
  for s in $@; do
    joined+="${s},"
  done
  echo ${joined%?}  # Removes last character, obviously
}

# Parameters
CLUSTER_ID=j-1GWDBJCW060Z3
JAR_FILE=simple-streaming-assembly-0.1.0.jar
MASTER_HOST=ip-10-100-129-186.ec2.internal

_SPARK_ARGS_=(
  --deploy-mode cluster
  --master yarn
  --num-executors 3
  --executor-cores 3
  --executor-memory 3g
  --files /var/tmp/log4j.properties
  --conf spark.driver.extraJavaOptions=-Dlog4j.debug=true
  --conf spark.executor.extraJavaOptions=-Dlog4j.debug=true
  --conf spark.driver.extraJavaOptions=-Dlog4j.configuration=file:log4j.properties
  --conf spark.executor.extraJavaOptions=-Dlog4j.configuration=file:log4j.properties
  --conf spark.dynamicAllocation.executorIdleTimeout=6000s
  --packages org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4
  --class runner.SimpleStreaming
  s3://spark-emr-test/jars/${JAR_FILE}  # These are arguments for the application
  ip-10-100-128-86.ec2.internal:9092
)
SPARK_ARGS=`join_by ${_SPARK_ARGS_[@]}`

# Builds a fat jar
sbt assembly

# Copies fat jar to S3
aws s3 cp --profile dev \
  target/scala-2.11/${JAR_FILE} \
  s3://spark-emr-test/jars/${JAR_FILE}

# Copy log4j file to master (until we find a better way to configure logging)
scp  -i ~/.ssh/spark-emr.pem \
     -o ProxyCommand="ssh -i ~/.ssh/spark-emr.pem -W ${MASTER_HOST}:22 bastion" \
     src/main/resources/log4j.properties \
     ec2-user@${MASTER_HOST}:/var/tmp/

# Triggers the computation in the choosen cluster
aws emr add-steps \
    --profile dev \
    --region us-east-1 \
    --cluster-id ${CLUSTER_ID} \
    --steps Type=SPARK,Name=SimpleStreaming,Args=[$SPARK_ARGS],\
ActionOnFailure=CONTINUE

