# ![Simple OAuth2 Logo](https://raw.github.com/simple-oauth2/simple_oauth2/master/logo.png)

[![Build Status](https://travis-ci.org/simple-oauth2/simple_oauth2.svg?branch=master)](https://travis-ci.org/simple-oauth2/simple_oauth2)
[![Gem Version](https://badge.fury.io/rb/simple_oauth2.svg)](https://badge.fury.io/rb/simple_oauth2)
[![Dependency Status](https://gemnasium.com/badges/github.com/simple-oauth2/simple_oauth2.svg)](https://gemnasium.com/github.com/simple-oauth2/simple_oauth2)
[![Coverage Status](https://coveralls.io/repos/github/simple-oauth2/simple_oauth2/badge.svg?branch=master)](https://coveralls.io/github/simple-oauth2/simple_oauth2?branch=master)
[![Code Climate](https://codeclimate.com/github/simple-oauth2/simple_oauth2/badges/gpa.svg)](https://codeclimate.com/github/simple-oauth2/simple_oauth2)
[![Inline docs](http://inch-ci.org/github/simple-oauth2/simple_oauth2.svg?branch=master)](http://inch-ci.org/github/simple-oauth2/simple_oauth2)
[![security](https://hakiri.io/github/simple-oauth2/simple_oauth2/master.svg)](https://hakiri.io/github/simple-oauth2/simple_oauth2/master)
[![License](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/simple-oauth2/simple_oauth2/blob/master/LICENSE)
[![git.legal](https://git.legal/projects/3504/badge.svg?key=6bcdf2e561e4c1cf2505 "Number of libraries approved")](https://git.legal/projects/3504)

A flexible OAuth2 server authorization and endpoints protection to your API

## Goal

The goal of this gem is provide a simple OAuth2 provider for different frameworks for example like Rails, Grape, Sinatra and e.t.c. Also this gem makes it easy to introduce OAuth2 provider functionality to your application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'simple_oauth2'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_oauth2

## Usage

1) You need to choose the **mixin** for your ORM and setup it. Please read the documentation about *mixin*. The list of mixins you can take a look at [here](#list-of-mixins).

2) **Important**. You need to create a file and put it in some place, that will be processed at the application startup. Also you need to configure *SimpleOAuth2* in order to provide authentication block.
```ruby
  # config/initializers/simple_oauth2_config.rb

  Simple::OAuth2.configure do |config|
    config.resource_owner_authenticator do |_request|
      User.find_by_id(session[:current_user_id])
    end
  end
```

3) Include `Simple::OAuth2` helpers.
```ruby
  # config/application.rb

  load File.expand_path('initializers/simple_oauth2_config.rb', __FILE__)

  include Simple::OAuth2::Helpers

  module Application
  end
```

4) Inject token authentication middleware into `config.ru`.
```ruby
  # config.ru

  require 'config/application'

  use Simple::OAuth2.middleware
```

5) And you need to define for example `Token`, `Authorization` and `RevokeToken` endpoints.
```ruby
  # config/application.rb

  load File.expand_path('initializers/simple_oauth2_config.rb', __FILE__)

  include Simple::OAuth2::Helpers

  module Application
    class Authorization
      def call(env)
        response = Simple::OAuth2::Generators::Authorization.generate_for(env)

        status = response.status
        headers = response.headers
        body = JSON.generate(response.body)

        [status, headers, [body]]
      end
    end

    class Token
      def call(env)
        response = Simple::OAuth2::Generators::Token.generate_for(env)

        status = response.status
        headers = response.headers
        body = JSON.generate(response.body)

        [status, headers, [body]]
      end
    end

    class RevokeToken
      def call(env)
        params = Rack::Request.new(env).params
        Simple::OAuth2::Generators::Token.revoke(params['token'], env)
      end
    end
  end
```

And define routes for them.
```ruby
  # config.ru

  require 'config/application'

  use Simple::OAuth2.middleware

  map '/oauth/token' do
    run Application::Token
  end

  map '/oauth/revoke_token' do
    run Application::RevokeToken
  end

  map '/oauth/authorization' do
    run Application::Authorization
  end
```

And that is all! Now we can run our app with bundle exec command.
```ruby
  bundle exec rackup config.ru
```

Use the next available routes.
```ruby
  POST /oauth/token
  POST /oauth/revoke_token
  POST /oauth/authorization
```

Also we can protect our endpoints with `access_token_required!` method. For example:
```ruby
  # config/application.rb
  # ...

  module Application
    # ...

    class Images
      def call(env)
        # public resource, no scopes required
        access_token_required!
        # or, requires 'write', 'read' scopes to exist in AccessToken
        access_token_required! :write, :read

        [200, { 'content-type' => 'application/json' }, [Image.all.to_json]]
      end
    end
  end
```

## List of mixins

- [NoBrainer](https://github.com/simple-oauth2/nobrainer_simple_oauth2)
- more coming soon

## Bugs and Feedback

Bug reports and feedback are welcome on GitHub at https://github.com/simple-oauth2/simple_oauth2/issues.

## Contributing

1. Fork the project.
1. Create your feature branch (`git checkout -b my-new-feature`).
1. Implement your feature or bug fix.
1. Add documentation for your feature or bug fix.
1. Add tests for your feature or bug fix.
1. Run `rake` and `rubocop` to make sure all tests pass.
1. Commit your changes (`git commit -am 'Add new feature'`).
1. Push to the branch (`git push origin my-new-feature`).
1. Create new pull request.

Thanks.

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/simple-oauth2/simple_oauth2/blob/master/LICENSE).

Copyright (c) 2016-2017 Volodimir Partytskyi (volodimir.partytskyi@gmail.com).
