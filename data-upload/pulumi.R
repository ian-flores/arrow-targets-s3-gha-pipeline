library(httr2)
library(jsonlite)
library(purrr)

get_stack <- function(org = Sys.getenv("PULUMI_ORG"),
                      project = Sys.getenv("PULUMI_PROJECT"),
                      stack = Sys.getenv("PULUMI_STACK"),
                      token = Sys.getenv("PULUMI_TOKEN")){
  
  url <- paste0("https://api.pulumi.com/api/stacks/", org,  "/", project, "/", stack, "/export")
  req <- httr2::request(url)
  req <- httr2::req_headers(req, 
                            "Content-Type" = "application/json", 
                            "Accept" = "application/vnd.pulumi+8",
                            "Authorization" = paste("token", token))

  resp <- httr2::req_perform(req)
  
  jsonResponse <- httr2::resp_body_json(resp)
  
  return(jsonResponse)
  
}

get_deployment <- function(pulumiStack){
  return(pulumiStack$deployment)
}

get_resources <- function(pulumiDeployment){
  return(pulumiDeployment$resources)
}

get_stack_outputs <- function(pulumiResources){
  stackOutputs <- pulumiResources[[1]]$outputs
  return(stackOutputs)
}

get_output_value <- function(pulumiStackOutputs, output_key){
  return(pulumiStackOutputs[[output_key]])
}