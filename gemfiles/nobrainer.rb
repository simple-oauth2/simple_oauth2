source 'https://rubygems.org'

gemspec path: '../'

gem 'nobrainer'

group :test do
  gem 'coveralls', require: false
  gem 'factory_girl', '~> 4.0'
  gem 'ffaker'
  gem 'rack-test', require: 'rack/test'
  gem 'rspec-rails', '~> 3.4'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
