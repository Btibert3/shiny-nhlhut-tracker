options(stringsAsFactors = FALSE)

## load the libraries
# library(neoimportR)
# library(RNeo4j)
# devtools::install_github("neo4j-rstats/neo4r")
library(neo4r)
library(dplyr)
library(janitor)
library(readr)
library(jsonlite)
library(tidyr)

## set the Neo4j path
NEO_PATH = "/Users/btibert/Library/Application Support/Neo4j Desktop/Application/neo4jDatabases/database-50b66423-2e01-45e5-bcb5-59c34aeea60b/installation-3.4.0/"
con = neo4j_api$new(url = "http://localhost:7474", user = "neo4j", password = "password")
con$get_version()

## load the data
load("hut20180523_1527128692.Rdata")
hutdb = hutdb %>% filter(!is.na(id))

## break out the synergies
syn_tmp = hutdb %>% select(id, synergy)
syns = data.frame()
for (i in 1:nrow(syn_tmp)) {
  x = syn_tmp[i, ]
  sj = fromJSON(x$synergy)
  sj = as.data.frame(sj)
  sj2 = sj %>% gather("synergy", "value")
  if (nrow(sj2)==0) {
    next
    cat("skipping ", i, "\n")
  }
  z = cbind(data.frame(id = x$id), sj2)
  z$value = as.numeric(z$value)
  syns = bind_rows(syns, z)
  cat("finished ", i, "\n")
}

## clean up synergies
syns %>% tabyl(value)
syns2 = syns %>% filter(value %in% 1:3)

## keep just the player data
players = hutdb %>% select(id, player:shoots, team, hgt, wgt, ovr:str)

## save out the csv datasets
FPATH = paste0(NEO_PATH, "/import/synergies.csv")
write_csv(syns2, FPATH, na="")
FPATH = paste0(NEO_PATH, "/import/players.csv")
write_csv(players, FPATH, na="")

## create the constraints
call_api("CREATE CONSTRAINT ON (n:Player) ASSERT n.id IS UNIQUE;", con)
call_api("CREATE CONSTRAINT ON (n:Synergy) ASSERT n.synergy IS UNIQUE;", con)
con$get_constraints()

## load the data via the load csv -- players
on_load_query <- "
MERGE (n:Player {id:row.id})
SET n += row
RETURN COUNT(*);
"
load_csv(url = "file:///players.csv", 
         on_load = on_load_query, 
         con = con, 
         header = TRUE, 
         periodic_commit = 500, 
         as="row")

## load the data via the load csv -- synergies
on_load_query <- "
MERGE (n:Synergy {synergy:row.synergy})
MERGE (p:Player {id:row.id})
CREATE (p)-[r:HAS_SYNERGY {value:row.value}]->(n)
RETURN COUNT(*);
"
load_csv(url = "file:///synergies.csv", 
         on_load = on_load_query, 
         con = con, 
         header = TRUE, 
         periodic_commit = 500, 
         as="row")


### do a clean import above, had to tweak queries?

## get brad marchand back

cql = "
MATCH (p:Player)-[r]->(x) 
WHERE p.player CONTAINS 'Brad Marchand'
RETURN p,r,x
"



################## 

player_atts = players %>% 
  select(id, wgt:str) %>% 
  gather("attribute", "value", -id)

player_info = players %>% 
  select(id:hgt)


