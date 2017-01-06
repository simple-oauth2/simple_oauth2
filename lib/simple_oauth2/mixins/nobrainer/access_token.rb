module Simple
  module OAuth2
    module NoBrainer
      # Includes all the required API, associations, validations and callbacks
      module AccessToken
        extend ActiveSupport::Concern

        included do # rubocop:disable Metrics/BlockLength
          include ::NoBrainer::Document
          include ::NoBrainer::Document::Timestamps

          before_save { self.updated_at = Time.now }
          before_validation :setup_expiration, if: :new_record?

          belongs_to :client, class_name: Simple::OAuth2.config.client_class_name,
                              foreign_key: :client_id, primary_key: :id
          belongs_to :resource_owner, class_name: Simple::OAuth2.config.resource_owner_class_name,
                                      foreign_key: :resource_owner_id, primary_key: :id

          field :resource_owner_id, type: String, required: true, index: true
          field :client_id, type: String, required: true, index: true
          field :token,
                type: String,
                required: true,
                uniq: true,
                index: true,
                default: -> { Simple::OAuth2.config.token_generator.generate }
          field :refresh_token,
                type: String,
                uniq: true,
                index: true,
                default: -> do
                  if Simple::OAuth2.config.issue_refresh_token
                    Simple::OAuth2.config.token_generator.generate
                  else
                    ''
                  end
                end
          field :scopes, type: String

          field :expires_at, type: Time, required: true
          field :revoked_at, type: Time
          field :created_at, type: Time, required: true, default: -> { Time.now }
          field :updated_at, type: Time, required: true, default: -> { Time.now }

          class << self
            def create_for(client, resource_owner, scopes = nil)
              create(client_id: client.id, resource_owner_id: resource_owner.id, scopes: scopes.to_s)
            end

            def authenticate(token, type = nil)
              t = token.to_s
              if type.to_s == 'refresh_token'
                where(refresh_token: t).first
              else
                where(token: t).first
              end
            end
          end

          def expired?
            expires_at && Time.now.utc > expires_at
          end

          def revoked?
            revoked_at && revoked_at <= Time.now.utc
          end

          def revoke!(revoked_at = Time.now)
            update!(revoked_at: revoked_at.utc)
          end

          def to_bearer_token
            {
              access_token: token,
              expires_in: expires_at && Simple::OAuth2.config.access_token_lifetime.to_i,
              refresh_token: refresh_token,
              scope: scopes
            }
          end

          private

          def setup_expiration
            expires_in = Simple::OAuth2.config.access_token_lifetime.to_i
            self.expires_at = Time.now + expires_in if expires_at.nil? && !expires_in.nil?
          end
        end
      end
    end
  end
end
