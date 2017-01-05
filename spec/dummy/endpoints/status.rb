module Twitter
  module Endpoints
    module StatusSingleScope
      def request
        @request
      end

      def call(env)
        @request = Rack::Request.new(env)
        @current_resource_owner = nil # Refresh cache instance variable
        @current_access_token = nil # Refresh cache instance variable

        access_token_required! :read
        body = JSON.dump(value: 'Access read', current_user_name: current_resource_owner.username)
        [200, { 'content-type' => 'application/json' }, [body]]
      end
    end

    module StatusMultipleScopes
      def request
        @request
      end

      def call(env)
        @request = Rack::Request.new(env)
        @current_resource_owner = nil # Refresh cache instance variable
        @current_access_token = nil # Refresh cache instance variable

        access_token_required! :read, :write
        body = JSON.dump(value: 'Access read, write', current_user_name: current_resource_owner.username)
        [200, { 'content-type' => 'application/json' }, [body]]
      end
    end

    module Status
      def request
        @request
      end

      def call(env)
        @request = Rack::Request.new(env)
        @current_resource_owner = nil # Refresh cache instance variable
        @current_access_token = nil # Refresh cache instance variable

        access_token_required!
        body = JSON.dump(value: 'Access', current_user_name: current_resource_owner.username)
        [200, { 'content-type' => 'application/json' }, [body]]
      end
    end
  end
end
