package runner

import org.apache.log4j.Logger
import org.apache.spark.sql.SparkSession

object SimpleStreaming {

  private val spark: SparkSession = SparkSession.builder()
    .appName("streams")
    .config("spark.sql.streaming.checkpointLocation", "/var/tmp/spark-checkpoints")
    .getOrCreate()

  private lazy val logger = Logger.getRootLogger

  def main(args: Array[String]): Unit = {
    println("I can find this log :)")
    logger.info("But not this one :(")

    spark.readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", args(0))
      .option("subscribe", "bureau.serasa_score")
      .load()
      .writeStream
      .outputMode("append")
      .format("console")
      .start()

    spark.streams.awaitAnyTermination()
  }
}
