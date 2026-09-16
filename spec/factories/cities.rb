FactoryBot.define do
  factory :city do
    sequence(:name_ar) { |n| "مدينة #{n}" }
    sequence(:name_en) { |n| "City #{n}" }
  end
end
