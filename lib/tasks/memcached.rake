require 'yaml'
require 'erb'

namespace :memcached do
  desc "Start memcached locally" 
  task :start do
    if RAILS_ENV == 'development'
      `net start "memcached Server"`
    else
      memcached memcached_config_args
      puts "memcached started"
    end
  end

  desc "Restart memcached locally" 
  task :restart do
    Rake::Task['memcached:stop'].invoke
    Rake::Task['memcached:start'].invoke
  end

  desc "Stop memcached locally" 
  task :stop do
    if RAILS_ENV == 'development'
      `net stop "memcached Server"`
    else
      `killall memcached`
      puts "memcached killed"
    end
  end
end

def memcached_config
  return @memcached_config if @memcached_config
  memcached_config  = YAML.load(ERB.new(IO.read(File.dirname(__FILE__) + '/../../config/memcached.yml')).result)
  @memcached_config = memcached_config['defaults'].merge(memcached_config['development'])
end

def memcached_config_args
  args = {
    '-p' => Array(memcached_config['servers']).first.split(':').last,
    '-c' => memcached_config['c_threshold'],
    '-m' => memcached_config['memory'],
    '-d' => ''
  }

  args.to_a * ' '
end

def memcached(*args)
  `memcached #{args * ' '}`
end
