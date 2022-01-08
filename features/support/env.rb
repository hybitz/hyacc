require 'daddy/cucumber/rails'

include HyaccConst

Dir[File.join(Rails.root, 'test', 'support', '*.rb')].each do |f|
  require f
  include File.basename(f).split('.').first.camelize.constantize
end
