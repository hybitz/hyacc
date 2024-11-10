ARG registry
FROM ${registry}/hyacc/base:latest

EXPOSE 3000

ADD config ./config
RUN sudo chown -R ${USER}:${USER} ./
RUN bundle exec rake dad:setup:app

ADD . ./
RUN sudo chown -R ${USER}:${USER} ./ && \
    bundle config unset --local "without" && \
    bundle install -j2
RUN bundle exec rake assets:precompile RAILS_ENV=production
