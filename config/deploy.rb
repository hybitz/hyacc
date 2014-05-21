# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'hyacc'
set :user, ENV['USER']
set :repo_url, 'git://github.com/hybitz/hyacc.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/var/www/my_app'
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  task :start do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service unicorn_hyacc_pro start"
      execute "sudo service memcached restart"
    end
  end
  task :stop do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service unicorn_hyacc_pro stop"
    end
  end
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo service unicorn_hyacc_pro restart"
      execute "sudo service memcached restart"
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
