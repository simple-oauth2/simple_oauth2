module Simple
  module OAuth2
    module NoBrainer
      # Includes all the required API, associations, validations and callbacks
      module Client
        extend ActiveSupport::Concern

        included do
          include ::NoBrainer::Document
          include ::NoBrainer::Document::Timestamps

          before_save { self.updated_at = Time.now }

          has_many :access_tokens, class_name: Simple::OAuth2.config.access_token_class_name, foreign_key: :client_id
          has_many :access_grants, class_name: Simple::OAuth2.config.access_grant_class_name, foreign_key: :client_id

          field :name, type: String, required: true
          field :redirect_uri, type: String, required: true
          field :key,
                type: String,
                required: true,
                index: true,
                uniq: true,
                default: -> { Simple::OAuth2.config.token_generator.generate }
          field :secret,
                type: String,
                required: true,
                index: true,
                uniq: true,
                default: -> { Simple::OAuth2.config.token_generator.generate }
          field :created_at, type: Time, required: true, default: -> { Time.now }
          field :updated_at, type: Time, required: true, default: -> { Time.now }

          def self.authenticate(key)
            where(key: key.to_s).first
          end
        end
      end
    end
  end
end
