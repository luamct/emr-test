#!/bin/bash

function join_by {
  for s in $@; do
    joined+="${s},"
  done
  echo ${joined%?}  # Removes last character, obviously
}

# Builds a fat jar
sbt assembly

JAR_FILE=simple-streaming-assembly-0.1.0.jar

# Copies fat jar to S3
aws s3 cp --profile dev \
  target/scala-2.11/${JAR_FILE} \
  s3://spark-emr-test/jars/${JAR_FILE}

# Arguments for the spark
ARGS_ARRAY=(
  --deploy-mode cluster
  --master yarn
  --num-executors 3
  --executor-cores 3
  --executor-memory 3g
#  --files s3://spark-emr-test/conf/log4j.properties
#  --conf spark.driver.extraJavaOptions=-Dlog4j.configuration=s3://spark-emr-test/conf/log4j.properties
  --conf spark.driver.extraJavaOptions=-Dlog4j.debug=true
  --packages org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4
  --class runner.SimpleStreaming
  s3://spark-emr-test/jars/${JAR_FILE}  # These are arguments for the application
  ip-10-100-128-86.ec2.internal:9092
)

ARGS=`join_by ${ARGS_ARRAY[@]}`

# Triggers the computation in the choosen cluster
aws emr add-steps \
    --profile dev \
    --region us-east-1 \
    --cluster-id j-1GWDBJCW060Z3 \
    --steps Type=SPARK,Name=SimpleStreaming,Args=[$ARGS],\
ActionOnFailure=CONTINUE
