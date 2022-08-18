require 'sql_monitor/version'
require 'sql_monitor/config'
require 'sql_monitor/engine'
require 'sql_monitor/railtie'
require 'sql_monitor/handler'
require 'sql_monitor/configuration'

module SqlMonitor
  class Error < StandardError; end

  def self.initialize!
    # puts "1. initialize sql_monitor"
    raise 'sql monitor initialized twice' if @already_initialized

    config = SqlMonitor::Config.apply_defaults
    @handler = SqlMonitor::Handler.new(config)
    @handler.subscribe
    @already_initialized = true
  end

  def self.setup!
    # puts "2. setup sql_monitor"
    @handler.setup
    at_exit { @handler.save } if SqlMonitor.configuration.save_at_exit
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

  class << self
    # Instantiate the Configuration singleton
    # or return it. Remember that the instance
    # has attribute readers so that we can access
    # the configured values
    def configuration
      @configuration ||= Configuration.new
    end

    # This is the configure block definition.
    # The configuration method will return the
    # Configuration singleton, which is then yielded
    # to the configure block. Then it's just a matter
    # of using the attribute accessors we previously defined
    def configure
      yield(configuration)
    end
  end
end
