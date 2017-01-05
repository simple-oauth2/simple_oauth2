$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'simple_oauth2/version'

Gem::Specification.new do |s|
  s.name        = 'simple_oauth2'
  s.version     = Simple::OAuth2.gem_version
  s.date        = '2017-01-03'
  s.summary     = 'OAuth2 authorization'
  s.description = 'A flexible OAuth2 server authorization'
  s.authors     = ['Volodimir Partytskyi']
  s.email       = 'volodimir.partytskyi@gmail.com'
  s.homepage    = 'https://github.com/0bman/simple_oauth2'
  s.license     = 'MIT'

  s.require_paths = %w(lib)
  s.files         = `git ls-files`.split($RS)

  s.required_ruby_version = '>= 2.2.2'

  s.add_runtime_dependency 'rack-oauth2', '~> 1.3.0', '>= 1.3.0'
end
