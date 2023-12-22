#FROM --platform=linux/amd64 rlespinasse/drawio-desktop-headless
FROM --platform=linux/amd64 jgraph/export-server

USER root

# fetching plantuml.jar is painfully slow so we do everything up front - hopefully this is cached most of the time
ENV PLANTUML_VERSION=1.2023.6
RUN apt update && apt install -y wget && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /opt/plantuml && wget "http://downloads.sourceforge.net/project/plantuml/${PLANTUML_VERSION}/plantuml.${PLANTUML_VERSION}.jar" -O /opt/plantuml/plantuml.jar


RUN apt update && apt install -y dumb-init default-jre graphviz && rm -rf /var/lib/apt/lists/*
RUN printf '#!/bin/sh\nexec java -Djava.awt.headless=true -jar /opt/plantuml/plantuml.jar "$@"' > /usr/bin/plantuml
RUN chmod +x /usr/bin/plantuml

RUN apt-get update && apt-get -y install python3 ruby-dev libffi-dev build-essential && rm -rf /var/lib/apt/lists/*

RUN gem install bundler

RUN useradd -ms /bin/bash builder
USER builder

WORKDIR /home/builder

RUN bundle config set --local path '/home/builder/.local/share/gem'


COPY --chown=builder _plugins/ /plugins/

ADD --chown=builder "https://github.com/wzab/wzab-code-lib/blob/677e701918fb1380cb14c1934c36f35b3bfa6786/drawio-support/drawio_select_layers.py" /plugins/

COPY --chown=builder layers.drawio ./

COPY --chown=builder Gemfile* ./

RUN bundle install

COPY --chown=builder invoke.sh ./
RUN chmod a+rx invoke.sh


ENTRYPOINT [ "/home/builder/invoke.sh" ]

CMD [ "--help" ]



#FROM --platform=linux/amd64 ruby:3.2.2-alpine
#
#ENV PLANTUML_VERSION=1.2023.6
#ENV LANG en_US.UTF-8
#
#WORKDIR /srv/jekyll
#
## construct a Jekyll builder that comes pre-installed with various useful builder tools (plantuml etc)
#
## general useful utils
#RUN apk add --no-cache wget curl ca-certificates
#
## plantuml
## using techniques from https://github.com/metanorma/plantuml-install/blob/main/alpine.sh
#RUN apk add --no-cache graphviz
#RUN apk add --no-cache font-dejavu font-droid font-droid-nonlatin fontconfig
#RUN apk add --no-cache plantuml --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
#RUN sed -i 's/java \-jar/java -Djava.awt.headless=true \-jar/' /usr/bin/plantuml
#
## drawio
#
#
#RUN wget https://github.com/wzab/wzab-code-lib/blob/677e701918fb1380cb14c1934c36f35b3bfa6786/drawio-support/drawio_select_layers.py
#
#
#
##RUN \
##  apk add --no-cache graphviz wget ca-certificates && \
##  apk add --no-cache graphviz wget ca-certificates ttf-dejavu fontconfig build-base  && \
##  wget "http://downloads.sourceforge.net/project/plantuml/${PLANTUML_VERSION}/plantuml.${PLANTUML_VERSION}.jar" -O /usr/bin/plantuml.jar
#
#EXPOSE 4000/tcp
#
#COPY Gemfile .

#gem update --system 3.4.13 \

# COPY plantuml /usr/bin
