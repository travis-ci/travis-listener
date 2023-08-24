FROM ruby:3.2.2-slim

LABEL maintainer Travis CI GmbH <support+travis-listener-docker-images@travis-ci.com>

# packages required for bundle install
RUN ( \
   apt-get update ; \
   apt-get install -y --no-install-recommends git make gcc \
   && rm -rf /var/lib/apt/lists/* \
)

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile      /app
COPY Gemfile.lock /app

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1
RUN bundle install --verbose --retry=3 --deployment --without development test

COPY . /app

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
