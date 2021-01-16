FROM hyacc/base:latest

EXPOSE 3000

ADD . ./
RUN sudo chown -R ${USER}:${USER} ./ && \
    bundle exec rake dad:setup:base
RUN bundle exec rake assets:precompile RAILS_ENV=production
