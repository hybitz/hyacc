require 'daddy/itamae'

include_recipe '../cookbooks/base.rb'

include_recipe 'selenium' unless ENV['SKIP_SELENIUM_INSTALLATION']
