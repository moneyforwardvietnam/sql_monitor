# frozen_string_literal: true

module SqlMonitor
  class ExplainSqlController < ActionController::Base
    protect_from_forgery with: :null_session

    def index
      data = ActiveRecord::Base.connection.execute("EXPLAIN #{params[:sql]}").first
      render json: {
        result: data.to_json
      }
    end
  end
end
