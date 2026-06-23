FactoryBot.define do
  factory :fixture do
    association :home_team, factory: :team
    association :away_team, factory: :team
    season { "2025-26" }
    matchweek { 1 }
    kickoff_at { 1.week.from_now }
    home_score { nil }
    away_score { nil }
    status { "scheduled" }

    trait :finished do
      status { "finished" }
      kickoff_at { 1.week.ago }
      home_score { 1 }
      away_score { 0 }
    end

    trait :kicked_off do
      kickoff_at { 1.minute.ago }
    end
  end
end
