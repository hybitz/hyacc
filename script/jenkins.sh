#!/bin/bash

PATH=$PATH:/usr/local/bin
export PATH

sudo /usr/local/bin/bundle update
rake db:migrate
rake ci:setup:testunit test
rcov --rails -Itest test/**/*_test.rb
