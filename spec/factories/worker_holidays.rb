FactoryBot.define do
  factory :worker_holiday do
    user { nil }
    worker { nil }
    holiday_date { "2026-09-17" }
    holiday_type { 1 }
    paid { false }
    notes { "MyText" }
  end
end
