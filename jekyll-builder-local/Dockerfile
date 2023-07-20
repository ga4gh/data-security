FROM ruby:3.2.2-alpine

ENV PLANTUML_VERSION=1.2023.6
ENV LANG en_US.UTF-8

WORKDIR /srv/jekyll
COPY Gemfile .

# construct a Jekyll builder that comes pre-installed with plantuml runnable as a binary
RUN \
  apk add --no-cache graphviz wget ca-certificates && \
  apk add --no-cache graphviz wget ca-certificates ttf-dejavu fontconfig build-base && \
  wget "http://downloads.sourceforge.net/project/plantuml/${PLANTUML_VERSION}/plantuml.${PLANTUML_VERSION}.jar" -O /usr/bin/plantuml.jar

EXPOSE 4000/tcp

#gem update --system 3.4.13 \

COPY plantuml /usr/bin
