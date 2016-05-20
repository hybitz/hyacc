require 'closer'

begin
  require 'cucumber/rails'
  Cucumber::Rails::Database.autorun_database_cleaner = false
rescue LoadError => e
  puts 'cucumber-rails not found.'
end

require 'daddy/cucumber'

include HyaccConstants

Dir[File.join(Rails.root, 'features', 'support', '*_support.rb')].each do |f|
  require f
end

if ENV['CI'] != 'travis'
  Before do |scenario|
    db_dump = DbDump.instance
    feature_file = scenario.feature.location.file

    if ARGV.include?(feature_file)
      if db_dump.current_feature.nil?
        db_dump.current_feature = feature_file
        db_dump.load
      end
    else
      unless db_dump.current_feature.nil?
        # 直前のDBをダンプしておく
        if db_dump.current_feature != feature_file
          db_dump.dump
          db_dump.current_feature = feature_file
        end
      end
    end
  end
end

Before do |scenario|
  resize_window(1280, 720)
end

After do |scenario|
  Cucumber.wants_to_quit = true if scenario.failed?
end
