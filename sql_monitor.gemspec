# -*- encoding: utf-8 -*-
# stub: sql_monitor 0.1.0 ruby lib

Gem::Specification.new do |s|
  s.name = "sql_monitor".freeze
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Tade".freeze]
  s.date = "2022-08-18"
  s.description = "Track and analyze sql queries of your rails application".freeze
  s.email = ["phan.minh.trung@moneyforward.vn".freeze]
  s.files = [".gitignore".freeze, ".rspec".freeze, ".travis.yml".freeze, "CODE_OF_CONDUCT.md".freeze, "Gemfile".freeze, "LICENSE.txt".freeze, "README.md".freeze, "Rakefile".freeze, "app/controllers/sql_monitor/explain_sql_controller.rb".freeze, "app/controllers/sql_monitor/tracking_sqls_controller.rb".freeze, "app/views/layouts/base.html.erb".freeze, "app/views/sql_monitor/tracking_sqls/index.html.erb".freeze, "bin/console".freeze, "bin/setup".freeze, "config/routes.rb".freeze, "lib/sql_monitor.rb".freeze, "lib/sql_monitor/config.rb".freeze, "lib/sql_monitor/engine.rb".freeze, "lib/sql_monitor/handler.rb".freeze, "lib/sql_monitor/railtie.rb".freeze, "lib/sql_monitor/version.rb".freeze, "sql_monitor.gemspec".freeze]
  s.homepage = "https://github.com/moneyforwardvietnam/sql_monitor".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.3.0".freeze)
  s.rubygems_version = "3.1.4".freeze
  s.summary = "SQL Query Monitor".freeze

  s.installed_by_version = "3.1.4" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_development_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_development_dependency(%q<rake>.freeze, [">= 0"])
    s.add_development_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
  else
    s.add_dependency(%q<bundler>.freeze, [">= 0"])
    s.add_dependency(%q<rake>.freeze, [">= 0"])
    s.add_dependency(%q<activesupport>.freeze, [">= 3.0.0"])
  end
end
