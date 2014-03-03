# coding: UTF-8
#
# $Id: deploy.rb 3201 2014-01-22 03:59:09Z ichy $
# Product: hyacc
# Copyright 2009-2014 by Hybitz.co.ltd
# ALL Rights Reserved.
#
set :default_run_options, :pty => true
set :use_sudo, false

set :application, "hyacc"
set :repository,  "git://github.com/hybitz/hyacc.git"
set :scm, :git
set :branch, 'release'

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :user, ENV['USER']
set :deploy_via, :remote_cache
set :deploy_to, "/home/#{user}/apps/#{application}"

set :keep_releases, 5

role :web, "localhost"                          # Your HTTP server, Apache/etc
role :app, "localhost"                          # This may be the same as your `Web` server
role :db,  "localhost", :primary => true # This is where Rails migrations will run

# 各ウェブアプリ個別の設定ファイルを転送
after "deploy:symlink" do
#  run "rm -f #{deploy_to}/current/config/database.yml"
#  run "scp -i #{identity} #{deploy_from}/config/database.yml #{deploy_to}/current/config"

#  run "rm -f #{deploy_to}/current/config/memcached.yml"
#  run "scp -i #{identity} #{deploy_from}/config/memcached.yml #{deploy_to}/current/config"
end

# if you want to clean up old releases on each deploy uncomment this:
after "deploy:start", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true } do 
    run "sudo service unicorn_hyacc_pro start"
  end
  task :stop, :roles => :app, :except => { :no_release => true } do 
    run "sudo service unicorn_hyacc_pro stop"
  end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "sudo service unicorn_hyacc_pro restart"
  end
end
