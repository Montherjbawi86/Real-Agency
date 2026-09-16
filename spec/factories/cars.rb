FactoryBot.define do
  factory :car do
    association :user, factory: :car_agent
    association :city
    title { "تويوتا كامري 2020" }
    description { "سيارة بحالة ممتازة، صيانة دورية، بدون حوادث" }
    brand { "تويوتا" }
    car_model { "كامري" }
    year { 2020 }
    price { 85_000 }
    currency { "USD" }
    mileage { 45_000 }
    fuel_type { :petrol }
    transmission { :automatic }
    condition { :used }
    body_type { :sedan }
    status { :published }
  end
end
