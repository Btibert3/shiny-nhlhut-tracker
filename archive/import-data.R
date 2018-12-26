options(stringsAsFactors = FALSE)

## load the packages
library(neo4r)
library(stringr)
library(jsonlite)
library(dplyr)
library(tidyr)
library(stringr)

## connect to the running neo4j database that is running locally in docker
con <- neo4j_api$new(url = "http://localhost:7474", 
                     user = "neo4j", 
                     password = "password")

## ensure that the constraints are there
call_api("CREATE CONSTRAINT ON (n:Card) ASSERT n.id IS UNIQUE;", con, output="r")


## check the sequence number of N = 5800 below, NEW CARDS ADDED so need to raise
for (i in seq(0, 5900, 100)) {
  ## the url
  URL = "https://hutdb.net/ajax/stats.php?year=19&page=%s&selected=OVR&sort=DESC"
  URL2 = sprintf(URL, i)
  results = fromJSON(URL2)
  players = results %>% filter(!is.na(Player)) %>% select(-results)
  colnames(players) = tolower(colnames(players))
  players = players %>% mutate_at(vars(year, wgt:salary, age:jersey), funs(as.numeric))
  players = players %>% select(id, ovr, card, team, player, position, shoots, type)
  for (p in 1:nrow(players)) {
    CQL = "
      MERGE (n:Card {id:'%s'})
      ON CREATE SET n.ovr = '%s',
                    n.card = '%s',
                    n.team = '%s',
                    n.player = '%s',
                    n.position = '%s',
                    n.shoots = '%s',
                    n.type = '%s'
      RETURN n
      "
    player = players[p, ]
    CQL = sprintf(CQL, player$id, 
                  player$ovr, 
                  player$card, 
                  player$team,
                  player$player,
                  player$position,
                  player$shoots,
                  player$type)
    call_api(CQL, con)
  }
  rm(URL2, results, players, CQL)
  message("finished ", i, "\n")
}