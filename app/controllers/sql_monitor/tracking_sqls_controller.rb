# frozen_string_literal: true

require 'json'

module SqlMonitor
  class TrackingSqlsController < ActionController::Base
    layout "base"

    def not_found
      respond_to do |format|
        format.any  { head :not_found }
      end
    end

    def index
      return not_found if Rails.env.production? || SqlMonitor.handler.nil?

      @versions = SqlMonitor.handler.redis.get('all_versions')
      if @versions.nil? || @versions.empty?
        @versions = []
      else
        @versions = JSON.parse(SqlMonitor.handler.redis.get('all_versions'), {:symbolize_names => true})
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

    def format_source(s)
      values = s.split(':')
      return [values[0] + ":" + values[1], s] if SqlMonitor.handler.config.repo_url.nil?

      [SqlMonitor.handler.config.repo_url % {file: values[0], line: values[1]}, s]
    end

    def format_data(sorted_data)
      formatedData = [];
      sorted_data.each do |row|
        sources = []
        row[:source].uniq.each do |s|
           sources << format_source(s)
        end

        formatedData.push({
          sql_key: row[:sql_key],
          count: row[:count].to_s,
          duration: row[:duration].to_f / row[:count],
          sql: row[:sql],
          sources: sources
        })
      end
      formatedData
    end

  end
end
