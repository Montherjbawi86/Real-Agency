FactoryBot.define do
  factory :payment do
    association :user
    association :contract
    association :tenant
    amount { 1000 }
    currency { "SYP" }
    due_on { Date.current }
    paid_on { nil }
    payment_method { :cash }
    status { :pending }
    notes { "دفعة إيجار شهرية" }
  end
end
