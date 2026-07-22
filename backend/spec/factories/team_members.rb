FactoryBot.define do
  factory :team_member do
    name { Faker::Name.name }
    sequence(:email) { |n| "member#{n}@supportflow.dev" }
    role { :developer }
    active { true }
  end
end
