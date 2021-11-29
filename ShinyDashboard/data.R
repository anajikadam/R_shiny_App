library(tidyverse)
library(httr)
library(jsonlite)

user_base <- read.csv("user_base.csv")

GetInsurance <- function() 
{
  path <- "https://health360.bh:5501/Provider/GetInsurance"
  request <- GET(url = path,   )
  
  response <- content(request, as = "text", encoding = "UTF-8")
  
  df <- fromJSON(response, flatten = TRUE) %>%  data.frame()
  GetInsurance <- select(df,
                         Groupname = data.Table.Groupname,
                         Groupid = data.Table.Groupid
  )
  return(GetInsurance)
}

Insurances_df = GetInsurance()

GetId <- function(gpname=1) 
{
  a <- Insurances_df %>% filter(Groupname == gpname)
  return(a[,'Groupid'])
}



GetCorporate <- function(insuredid) 
{
  #path <- "https://health360.bh:5501/Provider/GetCorporate?insuredid=1"
  path <- sprintf("https://health360.bh:5501/Provider/GetCorporate?insuredid=%s", insuredid)
  #print(path)
  request <- GET(url = path,   )
  
  response <- content(request, as = "text", encoding = "UTF-8")
  
  df <- fromJSON(response, flatten = TRUE) %>%  data.frame()
  Corporates_df <- select(df,
                          Groupname = data.Table.Groupname,
                          Groupid = data.Table.Groupid
  )
  return(Corporates_df)
}


Corporates_df = GetCorporate(insuredid)

GetId1 <- function(gpname=1) 
{
  a <- Corporates_df %>% filter(Groupname == gpname)
  return(a[,'Groupid'])
}


GetPolicy <- function(groupid) 
{
  #path <- "https://health360.bh:5501/Provider/GetPolicy?groupid=922"
  path <- sprintf("https://health360.bh:5501/Provider/GetPolicy?groupid=%s", groupid)
  #print(path)
  request <- GET(url = path,   )
  
  response <- content(request, as = "text", encoding = "UTF-8")
  
  df <- fromJSON(response, flatten = TRUE) %>%  data.frame()
  Policy_df <- select(df,
                      PolicyNo = data.Table.PolicyNo,
                      PolicyID = data.Table.PolicyID
  )
  return(Policy_df)
}

#Policy_df = GetPolicy(groupid)
#print(Insurances_df)
#print(Corporates_df)