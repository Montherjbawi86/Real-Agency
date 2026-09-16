FactoryBot.define do
  factory :worker do
    association :user, factory: :property_agent
    full_name { "عامل تجريبي" }
    phone { "0991111111" }
    position { "حارس" }
    salary { 500_000 }
    currency { "SYP" }
    hired_on { Date.current }
    active { true }
  end
end
