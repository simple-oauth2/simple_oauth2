FactoryGirl.define do
  factory :user do
    username FFaker::Internet.user_name
    encrypted_password FFaker::Internet.password
  end
end
