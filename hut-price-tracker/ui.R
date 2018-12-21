#
# UI to design a search for a player, see card, and log prices 
#

library(shiny)



# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("NHL19 HUT Market Price Tracker"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        
        sidebarPanel(
            ## have to use multiple =TRUE for no entry to display, choices=NULL b/c controlled server side 
            selectizeInput("player", label="Player", 
                           choices=NULL,  
                           multiple=TRUE)
        ),

        # Show a plot of the generated distribution
        mainPanel(
            numericInput("buynow", "Buy Now Pice", value=""),
            numericInput("current", "Current Price", value=""),
            numericInput("startprice", "Starting Price", value=""),
            br(),
            br(),
            actionButton("submit", "Submit")
        )
    ) #endlayout
))
