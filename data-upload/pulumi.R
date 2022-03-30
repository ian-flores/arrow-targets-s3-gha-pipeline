library(httr)
library(jsonlite)
library(magrittr)
library(purrr)

get_stack <- function(org = Sys.getenv("PULUMI_ORG"),
                      project = Sys.getenv("PULUMI_PROJECT"),
                      stack = Sys.getenv("PULUMI_STACK"),
                      token = Sys.getenv("PULUMI_TOKEN")){
  
  url <- paste0("https://api.pulumi.com/api/stacks/", org,  "/", project, "/", stack, "/export")
  req <- httr2::request(url) %>%
    httr2::req_headers("Content-Type" = "application/json", 
                       "Accept" = "application/vnd.pulumi+8",
                       "Authorization" = paste("token", token))

  resp <- httr2::req_perform(req)
  
  jsonResponse <- httr2::resp_body_json(resp)
  
  return(jsonResponse)
  
}

get_deployment <- function(pulumiStack){
  return(pulumiStack$deployment)
}

get_resources <- function(deployment){
  return(deployment$resources)
}

get_stack_outputs <- function(resources){
  outputs <- resources[[1]]$outputs
  return(outputs)
}

get_output_value <- function(outputs, output_key){
  return(outputs[[output_key]])
}