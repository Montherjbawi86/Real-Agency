FactoryBot.define do
  factory :salary_advance do
    user { nil }
    worker { nil }
    amount { "9.99" }
    currency { "MyString" }
    advance_date { "2026-09-17" }
    reason { "MyText" }
    settled { false }
    settled_on { "2026-09-17" }
  end
end
