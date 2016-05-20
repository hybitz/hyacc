# config valid only for current version of Capistrano
lock '3.5.0'

set :application, 'hyacc'
set :repo_url, `git config --get remote.origin.url`

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
set :branch, ENV['BRANCH'] || 'release'

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'
set :deploy_to, "/var/apps/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git
set :scm, :git
set :git_strategy, MyGitStrategy

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
set :linked_files, fetch(:linked_files, []).push('config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service memcached restart"
      execute "sudo service unicorn_hyacc_pro start"
    end
  end
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service unicorn_hyacc_pro stop"
    end
  end
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service memcached stop"
      execute "sudo service unicorn_hyacc_pro restart"
      execute "sudo service memcached start"
    end
  end

  after :publishing, :restart

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      within release_path do
        execute :rake, 'tmp:cache:clear'
      end
    end
  end

end
