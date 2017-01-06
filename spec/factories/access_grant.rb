FactoryGirl.define do
  factory :access_grant do
    resource_owner_id { User.create(attributes_for(:user)).id }
    client_id { Client.create(attributes_for(:client)).id }
    redirect_uri 'localhost:3000/home'

    factory :access_grant_with_read_scopes do
      scopes 'read'
    end

    factory :access_grant_with_read_and_write_scopes do
      scopes 'read,write'
    end
  end
end
