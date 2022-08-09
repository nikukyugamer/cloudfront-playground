require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module FreePlayground
  class Application < Rails::Application
    config.load_defaults 7.0
    config.time_zone = 'Tokyo'

    config.generators do |g|
      g.helper false
      g.test_framework false
    end
  end
end
