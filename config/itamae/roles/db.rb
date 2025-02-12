require 'daddy/itamae'

include_recipe '../cookbooks/base.rb'
include_recipe 'daddy::mysql::server'
include_recipe 'daddy::memcached::install'
