from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("PySparkJob").getOrCreate()

data = [("Alex", 1), ("Lee", 2)]
df = spark.createDataFrame(data, ["Name", "Age"])
df.show()

spark.stop()