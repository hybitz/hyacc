ARG registry
FROM ${registry}/hyacc/base:latest

EXPOSE 3000

ARG rails_env=production
ENV RAILS_ENV=${rails_env}

ADD Gemfile Gemfile.lock ./
RUN sudo chown -R ${USER}:${USER} ./ && \
    bundle config without 'development test' && \
    bundle install -j2

RUN mkdir -p app/assets/config
ADD app/assets/config/manifest.js app/assets/config/

ADD Rakefile ./
ADD config ./config
RUN sudo chown -R ${USER}:${USER} ./ && \
    bundle exec rake dad:setup:app

ADD . ./
RUN sudo chown -R ${USER}:${USER} ./ && \
    yarn install && \
    yarn cache clean && \
    bundle exec rake assets:precompile
