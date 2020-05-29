#!/usr/bin/env bash

# Build and submit
sbt assembly && spark-submit \
--class runner.SimpleStreaming \
--master "local[4]" \
--conf spark.driver.extraJavaOptions=-Dlog4j.configuration=file:src/main/resources/log4j.properties \
--conf spark.sql.streaming.checkpointLocation=/var/tmp/spark-checkpoints \
--packages org.apache.spark:spark-sql-kafka-0-10_2.11:2.4.4 \
target/scala-2.11/simple-streaming-assembly-0.1.0.jar \
localhost:9092
