require 'cucumber/rails'
require 'daddy'
require 'daddy/cucumber/helpers'

require 'capybara/rails'
ActionController::Base.allow_rescue = false

require 'capybara/cucumber'
require 'capybara/webkit' if ENV['DRIVER'] == 'webkit'
require 'capybara/poltergeist' if ENV['DRIVER'] == 'poltergeist'

Capybara.default_driver = (ENV['DRIVER'] || :selenium).to_sym
Capybara.default_selector = :css

include HyaccConstants

Before do |scenario|
  dump_dir = File.join('tmp', File.dirname(scenario.file), File.basename(scenario.file, '.feature'))

  if ARGV.include?(scenario.file)
    db = Dir.glob(File.join(dump_dir, '*.dump.gz')).first
    if db
      system("rake dad:db:load DUMP_FILE=#{db} --quiet")
    end
  else
    # 直前のDBをダンプしておく
    if @current_feature != scenario.file
      system("rm -Rf #{dump_dir}")
      system("rake dad:db:dump DUMP_DIR=#{dump_dir} --quiet")
      @current_feature = scenario.file
    end
  end

  resize_window(1280, 720)
end

After do |scenario|
  Cucumber.wants_to_quit = true if scenario.failed?
end
