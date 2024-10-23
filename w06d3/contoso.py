from pyspark.sql import SparkSession
from pyspark.sql import functions as F
from pyspark.sql import types as T

spark = SparkSession.builder.appName("contoso").getOrCreate()

calendar = spark.read.csv("dbfs:/FileStore/Calendar.csv", header=True)
channel = spark.read.csv("dbfs:/FileStore/Channel.csv", header=True)
geography = spark.read.csv("dbfs:/FileStore/Geography.csv", header=True)
product = spark.read.csv("dbfs:/FileStore/Product.csv", header=True)
product_category = spark.read.csv("dbfs:/FileStore/ProductCategory.csv", header=True)
product_subcategory = spark.read.csv("dbfs:/FileStore/ProductSubcategory.csv", header=True)
promotion = spark.read.csv("dbfs:/FileStore/Promotion.csv", header=True)
sale = spark.read.csv("dbfs:/FileStore/Sales.csv", header=True)
store = spark.read.csv("dbfs:/FileStore/Stores.csv", header=True)

dfs = {"calendar": calendar, "channel": channel, "geography": geography, "product": product, "product_category": product_category, "product_subcategory": product_subcategory, "promotion": promotion, "sale": sale, "store": store}

for df_name, df in dfs.items():
    print(df_name)
    print(df.schema)
    df.show(5)


for df_name, df in dfs.items():
        for c in df:
            null_values = df.filter(c.isNull())
            if null_values.count():
                print(df_name, c)
                null_values.show()

geography.filter(geography.GeographyType == "Continent").show()
store.filter(store.CloseReason.isNotNull()).show()

store = store.dropna(subset=["EmployeeCount"])


calendar.select(calendar.DateKey.substr(12, 8))\
    .distinct()\
    .show()

sale = sale.withColumn("DateKey", F.to_date(sale.DateKey, "dd/MM/yyyy"))\
    .withColumn("ProductKey", sale.ProductKey.cast("int"))
calendar = calendar.withColumn("DateKey", calendar.DateKey.cast("date"))
product = product.withColumn("ProductKey", product.ProductKey.cast("int"))

sale.join(calendar, "DateKey")\
    .join(product, "ProductKey")\
    .show()


sale = sale.withColumnRenamed("channelKey", "ChannelKey")\
    .withColumn("SalesAmount", sale.SalesAmount.cast(T.DecimalType(12, 2)))

sale.groupBy([F.year(sale.DateKey)\
    .alias("Year"), sale.ChannelKey])\
    .agg({"SalesAmount": "sum"})\
    .orderBy(["Year", "ChannelKey"])\
    .show()


sale.groupBy([F.year(sale.DateKey).alias("Year"), F.month(sale.DateKey).alias("Month")])\
    .agg({"SalesAmount": "sum"})\
    .orderBy(["Year", "Month"])\
    .show()
