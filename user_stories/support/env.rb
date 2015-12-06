require 'rails'
require 'daddy/cucumber/helpers'
require 'capybara/cucumber'
require 'capybara/poltergeist' if ENV['DRIVER'] == 'poltergeist'

Capybara.default_driver = (ENV['DRIVER'] || :selenium).to_sym
Capybara.default_selector = :css

include HyaccConstants

if ENV['CI'] != 'travis'
  Before do |scenario|
    feature_file = scenario.feature.location.file
    dump_dir = File.join('tmp', File.dirname(feature_file), File.basename(feature_file, '.feature'))
  
    if ARGV.include?(feature_file)
      db = Dir.glob(File.join(dump_dir, '*.dump.gz')).first
      if db
        system("rake dad:db:load DUMP_FILE=#{db} --quiet")
      end
    else
      # 直前のDBをダンプしておく
      if @current_feature != feature_file
        system("rm -Rf #{dump_dir}")
        system("rake dad:db:dump DUMP_DIR=#{dump_dir} --quiet")
        @current_feature = feature_file
      end
    end
  
    resize_window(1280, 720)
  end
end

Before do |scenario|
  resize_window(1280, 720)
end

After do |scenario|
  Cucumber.wants_to_quit = true if scenario.failed?
end
