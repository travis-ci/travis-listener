#!/bin/sh
cd /usr/src/app

bundle exec puma -C config/puma.rb
