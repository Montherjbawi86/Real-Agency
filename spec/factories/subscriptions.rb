FactoryBot.define do
  factory :subscription do
    user { nil }
    plan { nil }
    status { 1 }
    starts_on { "2026-09-16" }
    ends_on { "2026-09-16" }
    listings_used { 1 }
    notes { "MyText" }
  end
end
