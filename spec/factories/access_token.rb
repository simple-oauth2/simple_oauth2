FactoryGirl.define do
  factory :access_token do
    resource_owner_id { User.create(attributes_for(:user)).id }
    client_id { Client.create(attributes_for(:client)).id }

    factory :access_token_with_read_scopes do
      scopes 'read'
    end

    factory :access_token_with_read_and_write_scopes do
      scopes 'read,write'
    end
  end
end
