FactoryBot.define do
  factory :support_request do
    title { Faker::Lorem.sentence(word_count: 4) }
    description { Faker::Lorem.paragraph(sentence_count: 2) }
    status { :open }
    priority { :medium }
    due_date { nil }
    creator { association :team_member }
    team { association :team_member }
    assignee { nil }
  end
end