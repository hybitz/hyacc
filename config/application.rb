require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyacc
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    config.i18n.fallbacks = [:ja, :en]
    config.i18n.default_locale = :ja

    config.action_controller.action_on_unpermitted_parameters = :raise

    config.paths['config/routes.rb'] = Dir[Rails.root.join('config/routes/*.rb')] + config.paths['config/routes.rb']
end
end
