require 'factory_bot'
require 'faker'
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
  end
  factory :report do
    description { Faker::Name.name }
    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
  end
end
