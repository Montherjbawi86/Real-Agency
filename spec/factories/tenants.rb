FactoryBot.define do
  factory :tenant do
    association :user, factory: :property_agent
    association :property
    full_name { "مستأجر تجريبي" }
    phone { "0992222222" }
    national_id { "01234567890" }
    start_date { Date.current }
    end_date { 1.year.from_now }
    rent_amount { 1_000_000 }
    currency { "SYP" }
    active { true }
  end
end
