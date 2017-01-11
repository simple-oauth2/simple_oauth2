ENV['RAILS_ENV'] ||= 'test'
ENV['ORM']       ||= 'nobrainer'

ORM_GEMS_MAPPING = {
  'nobrainer' => 'nobrainer'
}.freeze

if RUBY_VERSION >= '1.9'
  require 'simplecov'
  require 'coveralls'

  SimpleCov.formatters = [
    SimpleCov::Formatter::HTMLFormatter,
    Coveralls::SimpleCov::Formatter
  ]

  SimpleCov.start do
    add_filter '/spec/'
    minimum_coverage(90)
  end
end

require 'rack/test'
require 'ffaker'
require ORM_GEMS_MAPPING[ENV['ORM']]
require File.expand_path("../dummy/orm/#{ENV['ORM']}/app/twitter", __FILE__)

APP = Rack::Builder.parse_file(File.expand_path("../dummy/orm/#{ENV['ORM']}/config.ru", __FILE__)).first

require 'support/helper'

RSpec.configure do |config|
  config.include Helper

  config.filter_run_excluding skip_if: true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.order = :random
  config.color = true

  config.before(:all) do
    I18n.load_path += Dir['./config/locales/*.yml']
    I18n.reload!
    NoBrainer.sync_schema
  end

  config.before(:each) do
    NoBrainer.purge!
    NoBrainer::Loader.cleanup
  end
end
