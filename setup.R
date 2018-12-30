## setup script to initialize the concept components needed

## global options
options(stringsAsFactors = FALSE)

## install
install.packages("optparse")

## load the libraries
library(neo4r)
library(optparse)
library(stringr)
library(jsonlite)
suppressMessages(library(dplyr))
library(tidyr)
library(stringr)


## connect to the running neo4j database that is running locally in docker
con <- neo4j_api$new(url = "http://localhost:7474",
                     user = "neo4j",
                     password = "password")

## ensure that the connection to the datastore is active
if (con$ping() !=200 ) {
  stop("unable to connect to the neo4j backend")
}


## configure the command line options and parse
parser <- OptionParser()
parser <- add_option(parser, c("--initneo"),
                     action = "store_true",
                     default = FALSE,
                     help = str_trim("This will delete all data, and ensure proper
                             indexes are setup."))
parser <- add_option(parser, c("--seedneo"),
                     action = "store_true",
                     default = FALSE,
                     help = str_trim("This will collect a new dataset and
                                     add any new cards to the database."))
parser <- add_option(parser, c("--genlist"),
                     action = "store_true",
                     default = FALSE,
                     help = str_trim("Query all of the Cards and generate the input list for faster access in the user layer."))
parser <- add_option(parser, c("--pricewipe"),
                     action = "store_true",
                     default = FALSE,
                     help = str_trim("This will delete all of the price entries in the database."))
argv = parse_args(parser)




## if initneo, wipe the data and ensure indexes in place
INITNEO = argv$initneo
if (INITNEO) {
  cat("wiping the database, as prompted\n")
  # Wipe the data
  CQL = "MATCH (n) DETACH DELETE n;"
  call_api(CQL,  con)
  # Create the constraints
  ## nothing set just yet
  ## call_api("CREATE CONSTRAINT ON (a:artist) ASSERT a.name IS UNIQUE;", con)
}


## seed the data
## if initneo, seed the data and ensure the proper indexes are in place
SEEDNEO = argv$seedneo
if (SEEDNEO) {
  ## ensure that the constraints are there
  call_api("CREATE CONSTRAINT ON (n:Card) ASSERT n.id IS UNIQUE;", con, output="r")
  cat("constraints are in place\n")

  ## check the sequence number of N = 5800 below, NEW CARDS ADDED so need to raise
  cat("paging through the dataset and ensuring that the cards are in the database, skipping otherwise\n")
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
      WITH n SET n.playerid = n.ovr+'-'+n.card+'-'+n.player
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


}

##TODO:  use the create date for the card and only flag "new" records for import by looking at the max create date in neo first

LISTARGS = argv$genlist
if (LISTARGS) {
  cat("fetching the cards from the database in the backend ....\n")
  ## bring the data back (yes, ineffecient) and save to data/hutdb.rds
  x = call_api("MATCH (n:Card) RETURN n", con, type="row", output="r")
  hutdb = x$n
  saveRDS(hutdb, "hut-price-tracker/hut.rds")
  cat("fetch complete \n")
}


WIPEPRICE = argv$pricewipe
if (WIPEPRICE) {
  call_api("MATCH (n:Price) DETACH DELETE n", con, type="row", output="r")
  cat("deleted all of the price nodes\n")
}
