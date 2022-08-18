module SqlMonitor
  class Railtie < ::Rails::Railtie

    # https://edgeapi.rubyonrails.org/classes/Rails/Railtie.html
    initializer 'sql_monitor.configure_rails_initialization' do
      SqlMonitor.initialize!
    end

    config.to_prepare do
      SqlMonitor.setup!
    end
  end
end
