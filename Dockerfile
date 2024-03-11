FROM ruby:3.2.2-slim

LABEL maintainer Travis CI GmbH <support+travis-listener-docker-images@travis-ci.com>

# packages required for bundle install
RUN ( \
   apt-get update ; \
   # update to deb 10.8
   apt-get upgrade -y ; \
   apt-get install -y --no-install-recommends git make gcc \
   && rm -rf /var/lib/apt/lists/* \
)

WORKDIR /app

RUN gem update --system 3.4.19 > /dev/null 2>&1

# Bundle config
RUN bundle config set --global no-cache 'true' && \
    bundle config set --global frozen 'true' && \
    bundle config set --global jobs `expr $(cat /proc/cpuinfo | grep -c 'cpu cores')` && \
    bundle config set --global retry 3 && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test'

COPY Gemfile Gemfile.lock ./

RUN bundle install

COPY . ./

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
