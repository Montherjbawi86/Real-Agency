FactoryBot.define do
  factory :maintenance do
    association :user, factory: :property_agent
    association :maintainable, factory: :property
    title { "تغيير زيت" }
    description { "تغيير زيت المحرك" }
    cost { 50_000 }
    currency { "SYP" }
    performed_on { Date.current }
    next_due_on { 3.months.from_now }
    kind { :general }
    status { :scheduled }
    parts { "فلتر زيت" }
  end
end
