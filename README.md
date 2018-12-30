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

The first time you fire up the app, you will need to locate the address of your neo4j browser and set the root password to `password`.  The Shiny app uses these creds to hit the neo4j.  Never do this in production.

If you are comfortable, you can run in detached model with `docker-compose up -d`.
