# About

This project is an idea to build a shiny app that does one thing well

Lookup an NHL HUT card, accurately, and allow the user to log the price to a
data store.


## Usage

1.  Build the Docker Images

- Neo4j

```
 docker build -t brock/neo4j ./docker/neo4j
```

-- Run the instance from within docker

Takes ~ 10-20s for neo4j to spin up and get to localhost:7474/browser.  
First time logging in will need to change the neo4j/neo4j user/pass combo which is default on a clean setup, as security is in-place by default.

```
docker-compose up -d .
```

## Notes before writing up

`setup.r` has command line switches

- wipe a databsae for a cleansetup if needed
- seendneo4j will either build a clean dataset (used with above) or add net-new cards to the database.

> neo4j docker takes about 10-30 seconds to spin up before it can be found on localhost browser if you are trying to find it quickly and might start wondering if something is wrong.


Dockerize Shiny App

https://www.bjoern-hartmann.de/post/learn-how-to-dockerize-a-shinyapp-in-7-steps/#step-3-create-a-dockerfile



## setup

Fire up DO with a droplet > 2gb of memory, get 3gb for 2.2cents/hour.

1.  Clone the repo for the app

```
git clone https://github.com/Btibert3/shiny-nhlhut-tracker.git
```

2.  Build the custom-ish neo4j Image

```
cd shiny-nhlhut-tracker/
docker build -t brock/neo4j ./neo4j
```

3.  Fire up the App

```
docker-compose up
```


This will keep the app running in the shell, which is handy for first time debugging, and prior to firing up, pull the rocker/tidyverse container if it has not already been pulled.  

> NOTE:  We are manually creating the user `neo4j` and the password for that user as `password`, which is only for demo purposes.

If you are comfortable, you can always run in detached model with `docker-compose up -d`.

To confirm that we can connect to the running server from our R/Shiny container, let's get into the container and run R so that we can poke around.

```
docker exec -it ef516832c810 R
```

We can find the id for our container with the `docker ps` command, in order to find the container of interest.


We are now using command-line (Base) R and can execute commands interactively.  

```
## install the package using devtools from github
devtools::install_github("neo4j-rstats/neo4r")
library(neo4r)
## point a connection at the server
con = neo4j_api$new(user="neo4j", password="password", url="http://neo4j:7474")
## confirm that we are connected with a 200
con$ping()
con$get_version()
## confirm that we have an empty database
call_api("MATCH (n) RETURN COUNT(n) as total", con)
## exit and go back to our host machine running our docker images
q()
```

Above the big thing to call out is the `url` parameter in the `con` object.  Instead of using `localhost`, we specified a connection from our R container to the other running Neo4j, and specified that with the `neo4j` name in `docker-compose.yml`.  

> Because containers are isolated by default, this setting allows us to create a connection between the two and avoid inputting a valid network address.

To exit from the interactive 'R' terminal within our container, we used `q()`.

Ok, thinks are looking good, but we want to seed our database with data and get our UI layer ready to go.

For this, we can use `setup.R` which we copied from the github repo to ~, and allows us to script commands within the `R` container.

First,  
