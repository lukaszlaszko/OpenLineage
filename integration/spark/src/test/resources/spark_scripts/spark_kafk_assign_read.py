from pyspark.sql import SparkSession

appName = "Kafka Examples"
master = "local"

spark = SparkSession.builder \
    .master(master) \
    .appName(appName) \
    .getOrCreate()

kafka_servers = "kafka:9092"
checkpointLocation = '/test_data/checkpoint'

df = spark \
    .read \
    .format("kafka") \
    .option("kafka.bootstrap.servers", kafka_servers) \
    .option("assign", '{"topicA": [0], "topicB": [0]}') \
    .load()

df.show()
