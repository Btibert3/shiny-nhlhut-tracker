options(stringsAsFactors = FALSE)

## load the libraries
library(jsonlite)
library(dplyr)
library(tidyr)
library(stringr)
library(neo4r)

## some constants
# URL = "https://hutdb.net/ajax/stats.php?year=18&page=%s&selected=OVR&sort=DESC"
URL = "https://hutdb.net/ajax/stats.php?year=19&page=%s&selected=OVR&sort=DESC"

## loop to get the data -- ONLYL SKATERS
hutdb = data.frame()
## check the sequence number of N = 5800 below, NEW CARDS ADDED
for (i in seq(0, 5800, 100)) {
  URL2 = sprintf(URL, i)
  results = fromJSON(URL2)
  players = results %>% filter(!is.na(Player)) %>% select(-results)
  colnames(players) = tolower(colnames(players))
  players = players %>% mutate_at(vars(year, wgt:salary, age:jersey), funs(as.numeric))
  hutdb = bind_rows(hutdb, players)
  #players_list = toJSON(players)
  #players_list = rjson::fromJSON(players_list)
  cat("finished ", i, "\n")
  rm(URL2, results, players)
}


## save the object as an RDS file to be read in by the server
saveRDS(hutdb, "data/hut.rds")




