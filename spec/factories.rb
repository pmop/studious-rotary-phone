require 'factory_bot'
require 'faker'
FactoryBot.define do
  factory :user, aliases: [:author, :commenter] do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
  end

  factory :report do
    association :user, factory: :user

    description { Faker::Name.name }
    lat { Faker::Address.latitude }
    lng { Faker::Address.longitude }
  end
end
def create_reports_from_desc_array(array)
  user = FactoryBot.create(:user)
  array.each do |desc|
    Report.create!(description: desc,
                   lat: 9.99,
                   lng: 9.99,
                   user_id: user.id)
  end
end
