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





