require 'digest/md5'
require 'json'
require 'fileutils'

require 'redis'
require "pry"
#
module SqlMonitor
  class Handler
    attr_reader :data, :cachedVerKey

    def initialize(config)
      @config = config
      @started_at = Time.now.to_s
      @data = {} # {key: {sql:, count:, duration, source: []}, ...}
    end

    def setup
      @redis = Redis.new(host: SqlMonitor.configuration.redis_host, db: SqlMonitor.configuration.redis_db)
      @cachedVerKey = SqlMonitor.configuration.release_version
      set_version
    end

    def redis
      @redis
    end

    def set_version
      versions = @redis.get('all_versions')
      if versions.nil? || versions.empty?
        versions = [{
          released_at: Time.now.to_s,
          version: @cachedVerKey
        }]
      else
        versions = JSON.parse(@redis.get('all_versions'), {:symbolize_names => true})
      end
      versions.push({
        released_at: Time.now.to_s,
        version: @cachedVerKey
      }) unless versions.map{|x|x[:version]}.include?(@cachedVerKey)
      @redis.set('all_versions', JSON.dump(versions))
    end

    def subscribe
      @subscription ||= ActiveSupport::Notifications.subscribe(
        'sql.active_record',
        self
      )
    end

    def unsubscribe
      return unless @subscription

      ActiveSupport::Notifications.unsubscribe(@subscription)

      @subscription = nil
    end

    def call(_name, started, finished, _id, payload)
      return unless @config.enabled

      sql = payload[:sql].dup
      return unless track?(sql)

      cleaned_trace = clean_trace(caller)
      return if cleaned_trace.empty?

      sql = clean_sql_query(sql)
      duration = 1000.0 * (finished - started) # in milliseconds
      sql_key = Digest::MD5.hexdigest(sql.downcase)

      if @data.key?(sql_key)
        update_data(sql_key, cleaned_trace, duration)
      else
        add_data(sql_key, sql, cleaned_trace, duration)
      end
    end

    def track?(sql)
      return true unless @config.tracked_sql_command.respond_to?(:join)
      tracked_sql_matcher =~ sql
    end

    def tracked_sql_matcher
      @tracked_sql_matcher ||= /\A#{@config.tracked_sql_command.join('|')}/i
    end

    def trace_path_matcher
      @trace_path_matcher ||= %r{^(#{@config.tracked_paths.join('|')})\/}
    end

    def clean_sql_query(query)
      query.squish!
      query.gsub!(/(\s(=|>|<|>=|<=|<>|!=)\s)('[^']+'|[\$\+\-\w\.]+)/, '\1xxx')
      query.gsub!(/(\sIN\s)\([^\(\)]+\)/i, '\1(xxx)')
      query.gsub!(/(\sBETWEEN\s)('[^']+'|[\+\-\w\.]+)(\sAND\s)('[^']+'|[\+\-\w\.]+)/i, '\1xxx\3xxx')
      query.gsub!(/(\sVALUES\s)\(.+\)/i, '\1(xxx)')
      query.gsub!(/(\s(LIKE|ILIKE|SIMILAR TO|NOT SIMILAR TO)\s)('[^']+')/i, '\1xxx')
      query.gsub!(/(\s(LIMIT|OFFSET)\s)(\d+)/i, '\1xxx')
      query
    end

    def clean_trace(trace)
      return trace unless defined?(::Rails)

      if Rails.backtrace_cleaner.instance_variable_get(:@root) == '/'
        Rails.backtrace_cleaner.instance_variable_set :@root, Rails.root.to_s
      end

      Rails.backtrace_cleaner.remove_silencers!

      if @config.tracked_paths.respond_to?(:join)
        Rails.backtrace_cleaner.add_silencer do |line|
          line !~ trace_path_matcher
        end
      end

      Rails.backtrace_cleaner.clean(trace)
    end

    def add_data(key, sql, trace, duration)
      @data[key] = {}
      @data[key][:sql] = sql
      @data[key][:count] = 1
      @data[key][:duration] = duration
      @data[key][:source] = [trace.first]

      # store new data
      @redis.set(@cachedVerKey + ':' + key, JSON.dump(@data[key]))
      # total sql keys
      @redis.set(@cachedVerKey + '_total', @data.keys.count)

      @data
    end

    def update_data(key, trace, duration)
      @data[key][:count] += 1
      @data[key][:duration] += duration
      @data[key][:source] << trace.first

      cachedData = JSON.parse(@redis.get(@cachedVerKey + ':' + key), {:symbolize_names => true})
      cachedData[:count] += 1
      cachedData[:duration] += duration
      cachedData[:source] << trace.first
      @redis.set(@cachedVerKey + ':' + key, JSON.dump(cachedData))

      @data
    end

    # save the data to file
    def save
      return if @data.empty?
      output = {}
      output[:data] = @data
      output[:generated_at] = Time.now.to_s
      output[:started_at] = @started_at
      output[:format_version] = '1.0'
      output[:rails_version] = Rails.version
      output[:rails_path] = Rails.root.to_s
      output[:cached_ver_key] = @cachedVerKey

      FileUtils.mkdir_p(@config.output_path)
      filename = "sql_monitor-#{Process.pid}-#{Time.now.to_i}.json"

      File.open(File.join(@config.output_path, filename), 'w') do |f|
        f.write JSON.dump(output)
      end
    end
  end
end
