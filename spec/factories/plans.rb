FactoryBot.define do
  factory :plan do
    name { "MyString" }
    name_ar { "MyString" }
    slug { "MyString" }
    price_syp { "9.99" }
    price_usd { "9.99" }
    max_listings { 1 }
    duration_days { 1 }
    features { "MyText" }
    active { false }
    position { 1 }
  end
end
