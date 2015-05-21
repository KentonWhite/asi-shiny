FROM r-base:latest

MAINTAINER Kenton White "kenton.white@advancedsymbolics.com"

RUN apt-get update && apt-get -y --force-yes install \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libxdmcp6=1:1.1.1-1+b1 \
    libxdmcp-dev \
    libx11-dev \
    libxrender-dev \
    libxext-dev \
    libxcb1-dev \
    libxcb-render0-dev \
    libxcb-shm0-dev \
    libcairo2-dev/unstable \
    libxt-dev \
    libxml2

# Download and install libssl 0.9.8
RUN wget --no-verbose http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl0.9.8_0.9.8o-4squeeze14_amd64.deb && \
    dpkg -i libssl0.9.8_0.9.8o-4squeeze14_amd64.deb && \
    rm -f libssl0.9.8_0.9.8o-4squeeze14_amd64.deb

# Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

RUN R -e "install.packages(c('ggvis', 'ProjectTemplate', 'reshape', 'plyr', 'dplyr', 'stringr', 'lubridate', 'changepoint', 'devtools'), dependencies = TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shiny', dependencies = TRUE, repos='http://cran.rstudio.com/')"
RUN apt-get -y --force-yes install libxml2-dev
RUN apt-get install -y r-cran-rjava libgdal1-dev libproj-dev
RUN R -e "install.packages(c('XML', 'RJDBC'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages(c('rgdal'), dependencies=TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('devtools', dependencies = TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('RJSONIO', dependencies = TRUE, repos='http://cran.rstudio.com/')"
RUN R -e "devtools::install_github('kentonwhite/esReader')"
RUN R -e "devtools::install_github('rstudio/leaflet')"
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
# COPY myapp /srv/shiny-server/

EXPOSE 80

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
