require 'active_support/configurable'
require 'uri'

module SqlMonitor
  class Config
    include ActiveSupport::Configurable
    config_accessor :redis_host, :tracked_paths, :tracked_sql_command, :output_path, :enabled, :redis_db, :release_version, :save_at_exit, :repo_url, :branch

    class << self
      def apply_defaults

        self.redis_host = redis_host.nil? ? 'localhost' : URI.parse(redis_host).host
        self.redis_db = redis_db.nil? ? 11 : redis_db
        self.release_version = release_version.nil? ? (0...50).map { ('a'..'z').to_a[rand(26)] }.join : release_version
        self.save_at_exit = save_at_exit.nil? ? false : save_at_exit
        self.repo_url = repo_url.nil? ? nil : repo_url.gsub('git@github.com:', 'https://github.com/').gsub('.git', "/blob/#{branch}/%{file}#L%{line}")

        self.enabled = enabled.nil? ? false : enabled
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
