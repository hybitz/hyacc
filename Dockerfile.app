ARG registry
FROM ${registry}/hyacc/base:latest

EXPOSE 3000

RUN bundle exec rake dad:setup:app

ADD . ./
RUN sudo chown -R ${USER}:${USER} ./

RUN bundle exec rake assets:precompile RAILS_ENV=production
