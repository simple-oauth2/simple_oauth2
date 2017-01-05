FactoryGirl.define do
  factory :client do
    name FFaker::Internet.domain_word
    redirect_uri 'localhost:3000/home'
  end
end
