FactoryBot.define do
  factory :payment_request do
    user { nil }
    subscription { nil }
    plan { nil }
    amount { "9.99" }
    currency { "MyString" }
    payment_method { 1 }
    reference_number { "MyString" }
    transfer_date { "2026-09-16" }
    sender_name { "MyString" }
    sender_phone { "MyString" }
    status { 1 }
    admin_notes { "MyText" }
    processed_at { "2026-09-16 15:25:41" }
    processed_by { 1 }
  end
end
