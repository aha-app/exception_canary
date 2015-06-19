# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exception_canary/version'

Gem::Specification.new do |spec|
  spec.name          = 'exception_canary'
  spec.version       = ExceptionCanary::VERSION
  spec.authors       = ['Zach Schneider']
  spec.email         = ['schneidmaster@gmail.com']

  spec.summary       = 'TODO: Write a short summary, because Rubygems requires one.'
  spec.description   = 'TODO: Write a longer description or delete this line.'
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  end

  spec.add_dependency 'coffee-rails'
  spec.add_dependency 'exception_notification', '>= 3.0.1'
  spec.add_dependency 'exception_notification-rake', '>= 0.0.5'
  spec.add_dependency 'jquery-rails'
  spec.add_dependency 'less-rails'
  spec.add_dependency 'less-rails-bootstrap', '~> 2.3.3'
  spec.add_dependency 'rails', '>= 3.0.4'
  spec.add_dependency 'react-rails'
  spec.add_dependency 'therubyracer'
  spec.add_dependency 'tilt'

  spec.add_development_dependency 'appraisal', '~> 1.0.0'
  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'capybara'
  spec.add_development_dependency 'factory_girl_rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'
end
