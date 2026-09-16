FactoryBot.define do
  factory :building do
    user { nil }
    city { nil }
    name { "MyString" }
    address { "MyString" }
    floors_count { 1 }
    units_per_floor { 1 }
    year_built { 1 }
    description { "MyText" }
    status { 1 }
  end
end
