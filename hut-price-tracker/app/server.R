#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#

## ensure necessary packages are installed
## not ideal for a docker situ, but get it working first
# install.packages("remotes")
remotes::install_github("neo4j-rstats/neo4r", quiet = TRUE)


## load the packages
library(shiny)
suppressPackageStartupMessages(library(dplyr))
library(neo4r)

## connect and send to neo4j, then disconnect
con <- neo4j_api$new(url = "http://neo4j:7474", 
                     user = "neo4j", 
                     password = "password")

## load the data every time the server loads -- loads a cache from the database to speed up
hutdb = readRDS("hut.rds")
# x = call_api("MATCH (n:Card) RETURN n", con, type="row", output="r")
# hutdb = x$n

## create a search term to help with overall and type
# hutdb = hutdb %>% 
#   transform(search_name = paste0(ovr, "-", card, "-", player)) %>% 
#   arrange(desc(search_name))


# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  ## update the players
  updateSelectizeInput(session, 'player', 
                       choices = hutdb$playerid, 
                       server = TRUE)
  
  ## get the player selection-- setup as multi for UX but only keep 1
  ##https://stackoverflow.com/questions/21515800/subset-a-data-frame-based-on-user-input-shiny
  player_sel = reactive({
    if(length(input$player)>0){
      x = filter(hutdb, playerid==input$player)
      return(x)
    }
  })
  
  ## write the data to neo4j from the inputs
  observeEvent(input$submit, {
    ## grab the data elements
    startprice = isolate(input$startprice)
    currentprice = isolate(input$current)
    bnprice = isolate(input$buynow)
    playerid = isolate(player_sel()$id)
    ## write the data to the table
    # submit_data = data.frame(id = playerid,
    #                          startprice = startprice,
    #                          currentprice = currentprice,
    #                          bnprice = bnprice)
    
    ## ssend the data to neo4j
    CQL = "
    MATCH (c:Card {id:'%s'})
    CREATE (p:Price {startprice:%d, 
                     currentprice:%d, 
                     bnprice:%d,
                     timestamp: datetime({ timezone: 'America/Los Angeles' }) })
    WITH c, p
    CREATE (c)-[:SPOT_PRICE]->(p)
    RETURN p

    "
    CYPHER = sprintf(CQL, playerid, startprice, currentprice, bnprice)
    call_api(CYPHER, con, output="json")
    rm(CQL, CYPHER)

    ## clear the inputs
    updateNumericInput(session, "startprice", value = "")
    updateNumericInput(session, "current", value = "0")
    updateNumericInput(session, "buynow", value = "")
    updateSelectizeInput(session, 'player', 
                         choices = hutdb$playerid, 
                         server = TRUE, selected = "")
  })
})
