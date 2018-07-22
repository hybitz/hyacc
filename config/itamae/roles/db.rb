require 'daddy/itamae'

include_recipe 'daddy::mysql::install'
include_recipe 'daddy::memcached::install'
include_recipe 'daddy::redis::install'
