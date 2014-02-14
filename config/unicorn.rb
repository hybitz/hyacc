# coding: UTF-8

require 'yaml'

rails_root = "#{File.dirname(File.expand_path(__FILE__))}/.."
rails_env = ENV['RAILS_ENV'] || 'development'

worker_processes 2
working_directory rails_root

database = YAML.load_file("#{File.dirname(__FILE__)}/database.yml")[rails_env]['database']
listen "/tmp/#{database}.sock"

stdout_path rails_root + '/log/unicorn.log'
stderr_path rails_root + '/log/unicorn.log'

preload_app true

before_fork do |server, worker|
  ActiveRecord::Base.connection.disconnect!
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end
end

after_fork do |server, worker|
  ActiveRecord::Base.establish_connection
end
