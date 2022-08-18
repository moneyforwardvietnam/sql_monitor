require 'sql_monitor/version'
require 'sql_monitor/config'
require 'sql_monitor/engine'
require 'sql_monitor/railtie'
require 'sql_monitor/handler'

module SqlMonitor
  class Error < StandardError; end

  def self.initialize!
    raise 'sql onitor initialized twice' if @already_initialized

    config = SqlMonitor::Config.apply_defaults
    handler = SqlMonitor::Handler.new(config)
    handler.subscribe
    @already_initialized = true

    at_exit { handler.save } if config.save_at_exit
  end

  def self.track
    config = SqlMonitor::Config.apply_defaults.new
    config.enabled = true
    handler = SqlMonitor::Handler.new(config)
    handler.subscribe
    yield
    handler.unsubscribe
    handler.data
  end
end
