# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

Rake::Task['db:migrate'].enhance do
  ENV['filename'] = 'doc/db_layout'
  ENV['attributes'] = 'foreign_keys, content, primary_keys, timestamp'
  ENV['exclude'] = 'ActiveRecord::SessionStore::Session, ActiveRecord::SchemaMigration'
  Rake::Task['erd'].invoke
end if Rails.env.development?
