require 'rake'

namespace :hyacc do
  namespace :redis do
    task :start do
      if system('sudo mkdir -p /data/hyacc/redis')
        system('docker run --name hyacc-redis --restart always --net host -v /data/hyacc/redis:/data -d redis redis-server --appendonly yes')
      end
    end
    
    task :stop do
      if `docker ps -q --filter "name=hyacc-redis"`.strip.size > 0
        system('docker stop hyacc-redis')
      end
      if `docker ps -qa --filter "name=hyacc-redis"`.strip.size > 0
        system('docker rm hyacc-redis')
      end
    end
    
    task :restart do
      Rake::Task['hyacc:redis:stop'].invoke
      Rake::Task['hyacc:redis:start'].invoke
    end
  end
end