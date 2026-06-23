FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:name)  { |n| "User #{n}" }
    app_admin { false }

    trait :app_admin do
      app_admin { true }
    end
  end
end
