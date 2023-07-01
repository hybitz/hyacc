require 'daddy/itamae'

include_recipe '../cookbooks/base.rb'

ENV['CHROME_DISABLE_GPG_CHECK'] = 'true'
include_recipe 'selenium'
