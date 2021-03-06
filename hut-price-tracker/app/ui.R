#
# UI to design a search for a player, see card, and log prices 
#

library(shiny)

# Define UI for application that draws a histogram
fluidPage(
  titlePanel("NHL HUT19 Price Tracker"),
  selectizeInput("player", label="Player", 
                 choices=NULL,  
                 multiple=TRUE),
  numericInput("current", "Current Price", value="0"),
  numericInput("buynow", "Buy Now Pice", value=""),
  numericInput("startprice", "Starting Price", value=""),
  br(),
  actionButton("submit", "Submit")
    
)
