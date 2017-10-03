library(jsonlite)
library(dplyr)
library(data.table)

setwd("C:/Data")

dt=list()

for (i in 1:2956) {
  message(paste("Process",i,"is runnning..."))
  con <- sprintf("alldata/%04d.jsonl",i)
  temp <- stream_in(file(con))
  dt[[i]] <- data.table(temp)
  }

dt <- rbindlist(dt)
save.image("C:/Data/originaldata.RData")