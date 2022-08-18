require 'uri'

module SqlMonitor
  class Configuration
    attr_accessor :redis_host, :redis_db, :save_at_exit, :release_version

    def initialize
      @redis_host = nil
      @save_at_exit = false
      @redis_db = 11
      @release_version = nil
    end

    def redis_host=(val)
      @redis_host = URI.parse(val).host
    end

    def save_at_exit=(val)
      @save_at_exit = val
    end

    def redis_db=(val)
      @redis_db = val
    end

    def release_version=(val)
      @release_version = val.nil? ? (0...50).map { ('a'..'z').to_a[rand(26)] }.join : val
    end
  end
end
