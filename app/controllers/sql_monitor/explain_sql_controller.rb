# frozen_string_literal: true

module SqlMonitor
  class ExplainSqlController < ActionController::Base

    def not_found
      respond_to do |format|
        format.any  { head :not_found }
      end
    end

    def index
      not_found if Rails.env.production?

      data = ActiveRecord::Base.connection.execute("EXPLAIN #{params[:sql]}").first
      render json: {
        result: data.to_json
      }
    end
  end
end
