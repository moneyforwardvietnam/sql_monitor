require 'active_support/configurable'

module SqlMonitor
  class Config
    include ActiveSupport::Configurable
    config_accessor :redis_host, :tracked_paths, :tracked_sql_command, :output_path, :enabled, :save_at_exit

    class << self
      def apply_defaults
        self.save_at_exit = save_at_exit.nil? ? false : save_at_exit
        self.redis_host = redis_host.nil? ? 'localhost' : redis_host
        self.enabled = enabled.nil? ? true : enabled
        self.tracked_paths ||= %w(app lib)
        self.tracked_sql_command ||= %w(SELECT INSERT UPDATE DELETE)
        self.output_path ||= begin
          if defined?(::Rails) && ::Rails.root
            File.join(::Rails.root.to_s, 'tmp')
          else
            'tmp'
          end
        end
        self
      end
    end
  end
end
