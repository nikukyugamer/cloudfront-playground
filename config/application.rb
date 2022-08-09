require_relative "boot"
require "rails/all"
Bundler.require(*Rails.groups)

module FreePlayground
  class Application < Rails::Application
    config.load_defaults 7.0

    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :utc

    I18n.config.available_locales = %i[en ja]
    I18n.default_locale = :ja

    config.generators do |g|
      g.assets     false
      g.helper     false

      g.test_framework(
        :rspec,
        fixtures: true,
        controller_specs: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      )
      g.fixture_replacement :factory_bot, dir: "spec/factories"
    end
  end
end