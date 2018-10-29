FROM ruby:2.5.1

LABEL maintainer Travis CI GmbH <support+travis-app-docker-images@travis-ci.com>

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile      /usr/src/app
COPY Gemfile.lock /usr/src/app

RUN gem install bundler
RUN bundle install

COPY . /usr/src/app

CMD bundle exec unicorn -p ${PORT-8080} -c ./config/unicorn.rb
