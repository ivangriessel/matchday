FactoryBot.define do
  factory :prediction do
    user
    fixture
    home_score { 1 }
    away_score { 1 }
    points { nil }
    submitted_at { nil }
  end
end
