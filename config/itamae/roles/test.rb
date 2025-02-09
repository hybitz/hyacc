require 'daddy/itamae'

include_recipe '../cookbooks/base.rb'
include_recipe 'daddy::mysql::client'
include_recipe 'selenium' unless ENV['REMOTE']
