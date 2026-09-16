FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@test.sy" }
    password { "password123" }
    full_name { "مستخدم تجريبي" }
    sequence(:phone) { |n| "09#{format('%08d', n)}" }
    role { :buyer }
  end

  factory :property_agent, parent: :user do
    role { :property_agent }
  end

  factory :car_agent, parent: :user do
    role { :car_agent }
  end
end
