FactoryBot.define do
  factory :team do
    sequence(:name)       { |n| "Team #{n}" }
    sequence(:short_code) { |n| "T#{n}" }
    crest_url { nil }
  end
end
