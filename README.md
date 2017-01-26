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

A flexible OAuth2 ([RFC 6749](https://tools.ietf.org/html/rfc6749)) server authorization and endpoints protection to your API with any ORM.

## Goal

The goal of this gem is provide a simple OAuth2 provider for different frameworks for example like Rails, Grape, Sinatra and e.t.c. Also this gem makes it easy to introduce OAuth2 provider functionality to your application.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Helpers](#helpers)
- [Custom authentication endpoints](#custom-authentication-endpoints)
- [Custom AccessToken authenticator](#custom-accesstoken-authenticator)
- [Custom scopes validation](#custom-scopes-validation)
- [Custom token generator](#custom-token-generator)
- [Process token on Refresh (protect against Replay Attacks)](#process-token-on-refresh-protect-against-replay-attacks)
- [[CORS] Cross Origin Resource Sharing](#cors-cross-origin-resource-sharing)
- [List of mixins](#list-of-mixins)
- [Bugs and Feedback](#bugs-and-feedback)
- [Contributing](#contributing)
- [License](#license)

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

The example below, it's a simple **Rack** application.

1) You need to choose the **mixin** for your ORM and setup it. Please read the documentation about *mixin*. The list of mixins you can take a look at [here](#list-of-mixins).
If you want to use this gem, but you can't find the mixin that you need, so then you have to create at least 4 classes (models) to cover OAuth2 roles and define a specific set to API for them as described [HERE](https://github.com/simple-oauth2/simple_oauth2/blob/master/OTHER_ORMS.md).
You can take a look at the **mixins** to understand what they are doing and what they are returning.

2) **Important**. You need to create a file and put it in some place, that will be processed at the application startup. Also you need to configure *SimpleOAuth2* in order to provide authentication block.
```ruby
  # config/initializers/simple_oauth2_config.rb

  Simple::OAuth2.configure do |config|
    config.resource_owner_authenticator do |request|
      User.find_by_id(request.params['user_id'])
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

Don't forget to define routes for them.
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

That's all! Now we can run our app with bundle exec command.
```ruby
  bundle exec rackup config.ru
```

Use the next available routes.
```ruby
  POST /oauth/token
  POST /oauth/revoke_token
  POST /oauth/authorization
```

## Helpers

Use the next available helpers.
```ruby
  access_token_required! :read, :write
  current_access_token
  current_resource_owner
```

We can protect our endpoints with `access_token_required!` method. For example:
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

This gem has ability to get `ResourceOwner` from the `AccessToken` found by `access_token` value passed with the request.
Also we can get `AccessToken` instance found by `access_token` value passed with the request.
For example:
```ruby
  class Images
    # ...

    def call(env)
      images = current_access_token.resource_owner.images
      # or
      images = current_resource_owner.images

      [200, { 'content-type' => 'application/json' }, [images.to_json]]
    end
  end
```

## Custom authentication endpoints

You can create your own API endpoints for OAuth2 authentication and use *simple_oauth2* gem functionality. In that case you will get a full control over the authentication proccess and can do anything in it.
```ruby
  # For Token endpoint
  #
  class Token
    def call(env)
      response = Simple::OAuth2::Generators::Token.generate_for(env) do |request, response|
        # You can use default authentication if you don't need to change this part:
        # client = Simple::OAuth2::Strategies::Base.authenticate_client(request)

        # Or write your custom client authentication:
        client = Application.find_by(key: request.client_id, active: true) || request.invalid_client!

        # You can use default Resource Owner authentication if you don't need to change this part:
        # resource_owner = Simple::OAuth2::Strategies::Base.authenticate_resource_owner(client, request)

        # Or define your custom resource owner authentication:
        resource_owner = User.find_by(username: request.username)
        request.invalid_grant! if resource_owner.nil? || resource_owner.inactive?

        # You can create an Access Token as you want:
        token = AccessToken.create(
          client: client,
          resource_owner: resource_owner,
          scope: request.scope
        )

        response.access_token = Simple::OAuth2::Strategies::Base.expose_to_bearer_token(token)
      end

      status = response.status
      headers = response.headers
      body = JSON.generate(response.body)

      [status, headers, [body]]
    end
  end
```
```ruby
  # For Authorization endpoint
  #
  class Authorization
    def call(env)
      response = Simple::OAuth2::Generators::Authorization.generate_for(env) do |request, response|
        # ...
      end

      # ...
    end
  end
```

## Custom AccessToken authenticator

If you don't want to use default Simple::OAuth2 AccessToken authenticator then you can define your own in the configuration (it must be a proc or lambda):
```ruby
  Simple::OAuth2.configure do |config|
    config.token_authenticator do |request|
      AccessToken.find_by(token: request.access_token) || request.invalid_token!
    end
  end
```

## Custom scopes validation

If you want to control the process of scopes validation (for protected endpoints for example) then you must implement your own class that will implement the following API:
```ruby
  class CustomScopesValidator
    # `scopes' is the set of required scopes that must be present in the AccessToken instance.

    def self.valid?(access_scopes, scopes)
      # custom scopes validation implementation...
    end
  end
```

And set that class as scopes validator in the Simple::OAuth2 config:
```ruby
  Simple::OAuth2.configure do |config|
    # ...

    config.scopes_validator_class_name = 'CustomScopesValidator'
  end
```

## Custom token generator

If you want to use JSON Web Tokens as a value for your Access Tokens, than you need to implement your custom Token Generator. First of all add [jwt gem](https://github.com/jwt/ruby-jwt) to your Gemfile:
If will do the main work for us in accordance to RFC 7519 standard. Now define custom token generator class:
```ruby
  class JWTGenerator
    HMAC_SECRET = '1d62ada3461$a091c38c95c!0388c8a1a2'.freeze

    # `payload` is a model attributes hash (in case of using some ORM)
    #
    def self.generate(payload = {}, options = {})
      JWT.encode(payload, HMAC_SECRET, 'HS256')

      # You can provide custom secrets if you need:
      #   JWT.encode(payload, options[:secret], 'HS256')
      #
      # or skip any encrypting at all:
      #   JWT.encode(payload, nil, 'none')
      #
      # @see https://github.com/jwt/ruby-jwt for more examples
    end
  end
```

And set it as a token generator class in the Simple::OAuth2 config:
```ruby
  Simple::OAuth2.configure do |config|
    # ...

    config.token_generator_class_name = 'JWTGenerator'
  end
```

## Process token on Refresh (protect against Replay Attacks)

If you want to do something with the original AccessToken that was used with the RefreshToken Flow, then you need to setup on_refresh configuration option. By default Simple::OAuth2 gem does nothing on token refresh and that option is set to :nothing. You can set it to the symbol (in that case AccessToken instance must respond to it) or block. Look at the examples:
```ruby
  Simple::OAuth2.configure do |config|
    # ...

    config.on_refresh = :destroy # will call :destroy method (`refresh_token.destroy`)
  end
```
```ruby
  Simple::OAuth2.configure do |config|
    # ...

    config.on_refresh do |refresh_token|
      refresh_token.destroy

      MyAwesomeLogger.info("Token ##{refresh_token.id} was destroyed on refresh!")
    end
  end
```

## [CORS] Cross Origin Resource Sharing

The most common solution for Rack-based applications is to use [rack-cors gem](https://github.com/cyu/rack-cors). It's a Rack middleware that will set required HTTP headers for you in order to be able to make Cross Domain requests to your application.
Add rack-cors to you Gemfile:
```ruby
  gem 'rack-cors', require: 'rack/cors'
```
In `config.ru` of your project configure Rack::Cors as follows:
```ruby
  # config.ru

  require 'rack/cors'

  # ...

  use Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: [:get, :post, :put, :delete, :options]
    end
  end
```
You can make any other CORS configuration, please read [the gem docs](https://github.com/cyu/rack-cors#configuration).

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
