# frozen_string_literal: true

require "rails"
require "action_controller/railtie"

module SqlMonitor
  class Engine < Rails::Engine
    isolate_namespace SqlMonitor
  end
end
