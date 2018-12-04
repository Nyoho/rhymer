FROM ubuntu:cosmic AS build
RUN apt-get update -qq && apt-get install -y build-essential git curl libpq-dev postgresql-client mecab libmecab-dev unzip

WORKDIR /tmp

RUN git clone --depth 1 https://github.com/neologd/mecab-unidic-neologd.git \
    && cd mecab-unidic-neologd \
    && ./bin/install-mecab-unidic-neologd -n -u -y \
    && cat build/*neologd*/*.csv | gzip > /tmp/union.csv.gz \
    && cd .. && rm -rf mecab-unidic-neologd

FROM ruby:2.5.3-alpine3.8
RUN apk upgrade --no-cache && \
    apk add --update --no-cache \ 
      build-base \
      postgresql-dev 

WORKDIR /app
COPY --from=build /tmp/union.csv.gz .

ENV DATABASE_HOST db

ADD app /app
RUN gem install bundler --pre
RUN bundle install
RUN apk del build-base
