library(arrow)
library(aws.s3)
library(tidyquant)
library(lubridate)
library(tidyverse)

# Get all the stocks listed in the NYSE
nyse_exchange <- tq_exchange("NYSE")

# Get all the stock prices from 2012-2021
stocks_df <- tq_get(nyse_exchange$symbol,
                      get  = "stock.prices",
                      from = "2012-01-01",
                      to   = "2022-01-01")

# Group by dates
stocks_grouped_by_date <- stocks_df %>%
  mutate(year = year(date),
         month = month(date),
         day = day(date)) %>%
  group_by(year, month, day)

# Group by stocks
stocks_grouped_by_stock <- stocks_df %>%
  group_by(symbol)

# Get S3 bucket name from the pulumi 
# stack deployed in infrastructure/
source("pulumi.R")

pulumiStack <- get_stack()
pulumiDeployment <- get_deployment(pulumiStack)
pulumiResources <- get_resources(pulumiDeployment)
pulumiOutputs <- get_stack_outputs(pulumiResources)

data_bucket_name <- get_output_value(pulumiOutputs, "data_bucket_name")

# Get {arrow} reference to S3 bucket
bucket <- s3_bucket(data_bucket_name)

# Create "grouped_by_date" folder
# Save the dataset to the bucket
put_folder("grouped_by_date", bucket = data_bucket_name)
grouped_by_date_folder <- bucket$cd("grouped_by_date")
write_dataset(dataset = stocks_grouped_by_date,
              path = grouped_by_date_folder,
              max_partitions = 4096)

# Create "grouped_by_stock" folder
# Save the dataset to the bucket
put_folder("grouped_by_stock", bucket = data_bucket_name)
grouped_by_stock_folder <- bucket$cd("grouped_by_stock")
write_dataset(dataset = stocks_grouped_by_stock,
              path = grouped_by_stock_folder,
              max_partitions = 4096)
