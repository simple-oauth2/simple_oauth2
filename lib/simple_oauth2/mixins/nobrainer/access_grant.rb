module Simple
  module OAuth2
    module NoBrainer
      # Includes all the required API, associations, validations and callbacks
      module AccessGrant
        extend ActiveSupport::Concern

        included do # rubocop:disable Metrics/BlockLength
          include ::NoBrainer::Document
          include ::NoBrainer::Document::Timestamps

          belongs_to :client, class_name: Simple::OAuth2.config.client_class_name,
                              foreign_key: :client_id
          belongs_to :resource_owner, class_name: Simple::OAuth2.config.resource_owner_class_name,
                                      foreign_key: :resource_owner_id

          before_save { self.updated_at = Time.now }
          before_validation :setup_expiration, if: :new_record?

          field :resource_owner_id, type: String, index: true
          field :client_id, type: String, required: true, index: true
          field :token,
                type: String,
                required: true,
                uniq: true,
                index: true,
                default: -> { Simple::OAuth2.config.token_generator.generate }
          field :redirect_uri, type: String, required: true
          field :scopes, type: String

          field :expires_at, type: Time, required: true
          field :revoked_at, type: Time
          field :created_at, type: Time, required: true, default: -> { Time.now }
          field :updated_at, type: Time, required: true, default: -> { Time.now }

          class << self
            def create_for(client, resource_owner, redirect_uri, scopes = nil)
              create(
                client_id: client.id,
                resource_owner_id: resource_owner.id,
                redirect_uri: redirect_uri,
                scopes: scopes.to_s
              )
            end

            def authenticate(token)
              where(token: token.to_s).first
            end

            private

            def setup_expiration
              self.expires_at = Time.now.utc + Simple::OAuth2.config.authorization_code_lifetime if expires_at.nil?
            end
          end
        end
      end
    end
  end
end
