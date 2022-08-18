# frozen_string_literal: true

Rails.application.routes.draw do
    get "/rails/tracking_sqls", to: "sql_monitor/tracking_sqls#index", as: 'rails_tracking_sqls'
    post "/rails/explain_sql", to: "sql_monitor/explain_sql#index", as: 'rails_explain_sql'
end
