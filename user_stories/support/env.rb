require 'closer'

begin
  require 'cucumber/rails'
  Cucumber::Rails::Database.autorun_database_cleaner = false
rescue LoadError => e
  puts 'cucumber-rails not found.'
end

require 'daddy/cucumber'

include HyaccConstants

if ENV['CI'] != 'travis'
  Before do |scenario|
    db_dump = DbDump.instance
    feature_file = scenario.feature.location.file
    dump_dir = File.join('tmp', File.dirname(feature_file), File.basename(feature_file, '.feature'))

    if ARGV.include?(feature_file)
      if db_dump.current_feature.nil?
        db = Dir.glob(File.join(dump_dir, '*.dump.gz')).first
        if db
          command = "bundle exec rake dad:db:load DUMP_FILE=#{db} --quiet"
          puts command
          system(command)
        end
        db_dump.current_feature = feature_file
      end
    else
      # 直前のDBをダンプしておく
      if db_dump.current_feature != feature_file
        puts feature_file.to_s
        system("rm -Rf #{dump_dir}")
        
        command = "bundle exec rake dad:db:dump DUMP_DIR=#{dump_dir} --quiet"
        puts command
        system(command)
        db_dump.current_feature = feature_file
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
