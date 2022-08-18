module SqlMonitor
  class Railtie < ::Rails::Railtie
    initializer 'sql_monitor.configure_rails_initialization' do
      SqlMonitor.initialize!
    end
  end
end
