FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    slug { nil } # generated from name by before_validation callback
  end
end
