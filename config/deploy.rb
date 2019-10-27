# config valid only for current version of Capistrano
lock '3.11.2'

set :application, 'hyacc'
set :repo_url, `git config --get remote.origin.url`.chomp

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['BRANCH'] || `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, "/var/apps/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, 'config/database.yml', 'config/secrets.yml'
append :linked_files, 'config/aws.yml', 'config/daddy.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
# append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :passenger_restart_with_sudo, true

namespace :deploy do

  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl start memcached"
    end
  end
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl stop memcached"
    end
  end
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo systemctl restart memcached"
    end
  end

  after :publishing, :restart

end
