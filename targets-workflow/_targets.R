library(targets)
source("../data-upload/pulumi.R")

pulumiStack <- get_stack()
pulumiDeployment <- get_deployment(pulumiStack)
pulumiResources <- get_resources(pulumiDeployment)
pulumiOutputs <- get_stack_outputs(pulumiResources)

data_bucket_name <- get_output_value(pulumiOutputs, "data_bucket_name")
targets_bucket_name <- get_output_value(pulumiOutputs, "targets_bucket_name")

tar_option_set(packages = c("arrow", "dplyr", "tarchetypes"),
               resources = tar_resources(
                 aws = tar_resources_aws(bucket = targets_bucket_name)),
               repository = "aws")

list(
  tar_target(
    data_bucket, 
    s3_bucket(data_bucket_name)
  ),
  tar_target(
    grouped_by_date_folder,
    data_bucket$cd("grouped_by_date")
  ),
  tar_target(
    arrow_dataset,
    open_dataset(grouped_by_date_folder)
  ),
  tar_target(
    current_month,
    as.integer(format(Sys.Date(), "%m"))
  ),
  tar_target(
    current_day,
    as.integer(format(Sys.Date(), "%d"))
  ),
  tar_target(
    red_month_df, 
    arrow_dataset %>%
      filter(open > close,
             month == current_month) %>%
      group_by(symbol) %>%
      collect() %>%
      count() %>%
      ungroup() %>%
      top_n(25) %>%
      arrange(desc(n)),
  ),
  tar_target(
    red_day_df,
    arrow_dataset %>%
      filter(open > close,
             day == current_day) %>%
      group_by(symbol) %>%
      collect() %>%
      count() %>%
      ungroup() %>%
      top_n(25) %>%
      arrange(desc(n))
  ),
  tarchetypes::tar_render(
    rmarkdown_report,
    "report/report.Rmd",
    output_file = "report.html",
    quiet = TRUE, 
    error = "continue"
  )
)
