#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'ci/reporter/rake/minitest'

Hyacc::Application.load_tasks

Rake::Task['environment'].enhance do
  Rake::Task['dad:app_base_dir'].invoke
end