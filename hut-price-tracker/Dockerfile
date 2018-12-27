FROM rocker/r-ver:3.5.2

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    xtail \
    wget 
    
# https://github.com/rocker-org/rocker/issues/124
RUN apt-get install -y libssl-dev


# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment && \
    R -e "install.packages(c('shiny', 'rmarkdown'), repos='$MRAN')" && \
    cp -R /usr/local/lib/R/site-library/shiny/examples/* /srv/shiny-server/

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /app /srv/shiny-server/

# Install R packages that are required
# TODO: add further package if you need!
RUN R -e "install.packages(c('remotes'), repos='http://cran.rstudio.com/')"
RUN R -e "remotes::install_github('neo4j-rstats/neo4r')"

CMD ["/usr/bin/shiny-server.sh"]