FROM ruby:2.5.1-alpine

# throw errors if Gemfile has been modified since Gemfile.lock
RUN apk update && apk add build-base git curl wget
RUN bundle config --global frozen 1
RUN mkdir -p /usr/src/app 
WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment --without development test

COPY . .

EXPOSE 3000
#ENTRYPOINT ["/usr/src/app/entrypoint.sh"]

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
