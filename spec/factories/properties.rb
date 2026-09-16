FactoryBot.define do
  factory :property do
    association :user, factory: :property_agent
    association :city
    title { "شقة فاخرة للبيع" }
    description { "شقة واسعة في موقع ممتاز مع جميع الخدمات" }
    property_type { :apartment }
    listing_type { :sale }
    price { 250_000_000 }
    currency { "SYP" }
    size { 140 }
    rooms { 3 }
    bathrooms { 2 }
    status { :published }
  end
end
