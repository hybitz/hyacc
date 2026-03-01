require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Hyacc
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.eager_load_paths << Rails.root.join('app/validations')

    config.time_zone = 'Tokyo'
    config.active_record.default_timezone = :local

    config.i18n.fallbacks = [:ja, :en]
    config.i18n.default_locale = :ja

    config.action_controller.action_on_unpermitted_parameters = :raise

    config.paths['config/routes.rb'] = Dir[Rails.root.join('config/routes/*.rb')] + config.paths['config/routes.rb']
  end
end
