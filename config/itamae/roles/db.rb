require 'daddy/itamae'

include_recipe '../cookbooks/base.rb'

package 'graphviz' do
  user 'root'
end

include_recipe '../cookbooks/gem.rb'
include_recipe 'daddy::mysql'
include_recipe 'daddy::memcached::install'
include_recipe '../cookbooks/cron.rb'
