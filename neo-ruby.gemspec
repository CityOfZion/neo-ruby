lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'neo'

Gem::Specification.new do |spec|
  spec.name          = 'neo-ruby'
  spec.version       = Neo.version
  spec.authors       = ['Jason L Perry']
  spec.email         = ['jason@suncoast.io']

  spec.summary       = 'Neo Ruby Library'
  spec.description   = 'A Ruby library for interacting with the NEO blockchain.'
  spec.homepage      = 'https://github.com/CityOfZio/neo-ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ['lib']

  spec.add_dependency 'eventmachine', '~> 1.2'

  spec.add_development_dependency 'bundler', '~> 1.16.a'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-autotest'
  spec.add_development_dependency 'minitest-ci'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'vcr', '~> 4.0'
  spec.add_development_dependency 'webmock', '~> 3.1'
end
