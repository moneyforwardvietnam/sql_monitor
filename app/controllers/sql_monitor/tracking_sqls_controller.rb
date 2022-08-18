# frozen_string_literal: true

require 'json'

module SqlMonitor
  class TrackingSqlsController < ActionController::Base
    layout "base"

    def index
      @versions = SqlMonitor.handler.redis.get('all_versions')
      if @versions.nil? || @versions.empty?
        @versions = []
      else
        @versions = JSON.parse(SqlMonitor.handler.redis.get('all_versions'), {:symbolize_names => true})
      end

      @versions.each do |v|
        v[:total] = SqlMonitor.handler.redis.get(v[:version] + "_total")
      end

      @data = []
      @selectedVersion = ''
      if params[:version]
        data = []
        @selectedVersion = params[:version]
        SqlMonitor.handler.redis.scan_each(match: @selectedVersion + ":*") do |v|
          data << JSON.parse(SqlMonitor.handler.redis.mGet(v).first, {:symbolize_names => true}).merge({sql_key: v.split(':')[1]})
        end
        @data = format_data(sort_data(data, 'count'))
      end
    end

    private
    def sort_data(data, sort_by)
      data.sort_by do |d|
        if sort_by == 'duration'
          -d[:duration].to_f / d[:count]
        else
          -d[:count]
        end
      end
    end

    def format_data(sorted_data)
      formatedData = [];
      sorted_data.each do |row|
        formatedData.push({
          sql_key: row[:sql_key],
          count: row[:count].to_s,
          duration: row[:duration].to_f / row[:count],
          sql: row[:sql],
          source: row[:source].uniq.join("<br/>")
        })
      end
      formatedData
    end

  end
end
