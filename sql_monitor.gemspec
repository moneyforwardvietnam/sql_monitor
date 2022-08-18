require_relative 'lib/sql_monitor/version'

Gem::Specification.new do |spec|
  spec.name          = "sql_monitor"
  spec.version       = SqlMonitor::VERSION
  spec.authors       = ["Tade"]
  spec.email         = ["phan.minh.trung@moneyforward.vn"]

  spec.summary       = 'SQL Query Monitor'
  spec.description   = 'Track and analyze sql queries of your rails application'
  spec.homepage      = 'https://github.com/moneyforwardvietnam/sql_monitor'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'activesupport', '>= 3.0.0'
end
