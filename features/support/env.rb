# coding: UTF-8

require 'cucumber/rails'
require 'daddy/cucumber'

module TestSupport
  Dir[File.join(Rails.root, 'test', 'support', '*.rb')].each do |f|
    self.class_eval File.read(f)
  end
end

World(TestSupport)
