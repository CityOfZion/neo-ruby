# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'neo/version'

Gem::Specification.new do |spec|
  spec.name          = 'neo-ruby'
  spec.version       = Neo.version
  spec.authors       = ['Jason L Perry']
  spec.email         = ['jason@cityofzion.io']

  spec.summary       = 'Neo Ruby Library and SDK'
  spec.description   = 'A Ruby library for interacting with and creating smart contracts the NEO blockchain.'
  spec.homepage      = 'https://github.com/CityOfZio/neo-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_dependency 'eventmachine', '~> 1.2'
  spec.add_dependency 'parser'

  spec.add_development_dependency 'bundler', '~> 1.16a'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'guard', '~> 2.14'
  spec.add_development_dependency 'guard-minitest', '~> 2.4'
  spec.add_development_dependency 'guard-rubocop', '~> 1.3'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-autotest', '~> 1.0'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rubocop', '~> 0.54.0'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'webmock', '~> 3.1'
end
