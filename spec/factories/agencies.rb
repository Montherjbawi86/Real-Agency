FactoryBot.define do
  factory :agency do
    association :user, factory: :property_agent
    association :city
    name { "وكالة النخبة" }
    kind { :property }
    phone { "0113333333" }
    whatsapp { "0993333333" }
    address { "شارع المزة" }
    description { "وكالة عقارية متخصصة" }
  end
end
