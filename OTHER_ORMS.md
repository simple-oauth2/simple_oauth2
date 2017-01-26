# Other ORMs
If you want to use this gem, but you can't find the mixin that you need, so then you have to create at least 4 classes (models) to cover OAuth2 roles and define a specific set to API for them as described below.

## Client
Class that represents an OAuth2 Client should contain the following API:

```ruby
  # app/models/client.rb

  class Client
    # ...

    def self.by_key(key)
      # Should return a Client instance matching the `key`.
      #
      # @example where(key: key).first
    end
  end
```

## AccessToken
Class that represents an OAuth2 Access Token you must define the next API:

```ruby
  # app/models/access_token.rb

  class AccessToken
    # ...

    def self.by_token(token)
      # Returns an AccessToken instance matching the `token` provided.
      #
      # @example where(token: token).first
    end

    def self.by_refresh_token(refresh_token)
      # Returns an AccessToken instance matching the `refresh_token` provided.
      #
      # @example where(refresh_token: refresh_token).first
    end

    def self.create_for(client, resource_owner, scopes = nil)
      # Creates the record in the database for the provided `client` and
      # `resource_owner` with specific `scopes` (if present).
      # Returns an instance of that record.
      #
      # @example
      #   create(
      #     client_id: client.id,
      #     resource_owner_id: resource_owner.id,
      #     scopes: scopes
      #   )
    end

    def client
      # Returns associated Client instance.
      # For ORM objects it can be an association (`belongs_to :client` for ActiveRecord).
    end

    def resource_owner
      # Returns associated ResourceOwner instance.
      # For ORM objects it can be an association (`belongs_to :resource_owner` for ActiveRecord).
    end

    def expired?
      # true if the AccessToken has reached its expiration.
    end

    def revoked?
      # true if the AccessToken was revoked.
    end

    def revoke!(revoked_at = Time.now.utc)
      # Revokes an AccessToken (by setting its :revoked_at attribute to the specific time).
      #
      # @example update!(revoked_at: revoked_at)
    end

    def to_bearer_token
      # Returns a Hash of Bearer token attributes like the following:
      #   access_token: '',      # - required
      #   expires_in: '',        # - required
      #   refresh_token: '',     # - optional
      #   scope: ''              # - optional
    end
  end
```

## ResourceOwner
Class that represents an OAuth2 ResourceOwner should contain the following API:

```ruby
  # app/models/user.rb

  class User
    # ...

    def self.oauth_authenticate(client, username, password)
      # Returns an instance of the User class with matching username
      # and password. If there is no such User or password doesn't match then returns nil.
      #
      # @example
      #   user = where(username: username.to_s).first
      #   user if user && user.encrypted_password == password
    end
  end
```

## AccessGrant
Class that represents an OAuth2 AccessGrant should contain the following API:

```ruby
  # app/models/access_grant.rb

  class AccessGrant
    # ...

    def self.by_token(token)
      # Returns an AccessGrant instance matching the `token` provided.
      #
      # @example where(token: token).first
    end

    def self.create_for(client, resource_owner, redirect_uri, scopes = nil)
      # Creates the record in the database for the provided `client`,
      # `resource_owner` and `redirect_uri` with specific `scopes` (if present).
      # Returns an instance of that record.
      #
      # @example
      #   create(
      #     client_id: client.id,
      #     resource_owner_id: resource_owner.id,
      #     redirect_uri: redirect_uri,
      #     scopes: scopes
      #   )
    end

    def client
      # Returns associated Client instance.
      # For ORM objects it can be an association (`belongs_to :client` for ActiveRecord).
    end

    def resource_owner
      # Returns associated ResourceOwner instance.
      # For ORM objects it can be an association (`belongs_to :resource_owner` for ActiveRecord).
    end
  end
```
