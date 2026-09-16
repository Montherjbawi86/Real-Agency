FactoryBot.define do
  factory :worker_payment do
    user { nil }
    worker { nil }
    amount { "9.99" }
    currency { "MyString" }
    paid_on { "2026-09-17" }
    for_month { "2026-09-17" }
    payment_method { 1 }
    notes { "MyText" }
  end
end
