FactoryBot.define do
  factory :contract do
    association :user, factory: :property_agent
    association :property
    association :tenant
    start_date { Date.current }
    end_date { 1.year.from_now }
    amount { 12_000_000 }
    currency { "SYP" }
    status { :active }
    notes { "عقد إيجار سنوي" }
  end
end
