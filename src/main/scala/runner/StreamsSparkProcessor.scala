package runner

import org.slf4j.LoggerFactory
import org.apache.spark.sql.SparkSession

object StreamsSparkProcessor {

  private val spark: SparkSession = SparkSession.builder()
    .appName("streams")
    .config("spark.sql.streaming.checkpointLocation", "/var/tmp/spark-checkpoints")
    .getOrCreate()

  private lazy val logger = LoggerFactory.getLogger("root")

  def main(args: Array[String]): Unit = {
    println("I can find this log")
    logger.info("But not this one :(")
  }
}
