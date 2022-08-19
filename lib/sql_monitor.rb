require 'sql_monitor/version'
require 'sql_monitor/config'
require 'sql_monitor/engine'
require 'sql_monitor/railtie'
require 'sql_monitor/handler'

module SqlMonitor
  class Error < StandardError; end

  def self.initialize!
    # puts "1. initialize sql_monitor"
    raise 'sql monitor initialized twice' if @already_initialized
    @already_initialized = true
  end

  def self.setup!
    # puts "2. setup sql_monitor"
    config = SqlMonitor::Config.apply_defaults
    return unless config.enabled

    @handler = SqlMonitor::Handler.new(config)
    @handler.subscribe
    at_exit { @handler.save } if config.save_at_exit
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

  def self.handler
    @handler
  end
end
