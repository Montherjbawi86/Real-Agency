# Cities
cities = [
  ["دمشق", "Damascus"], ["ريف دمشق", "Rural Damascus"], ["حلب", "Aleppo"],
  ["حمص", "Homs"], ["حماة", "Hama"], ["اللاذقية", "Latakia"],
  ["طرطوس", "Tartus"], ["إدلب", "Idlib"], ["دير الزور", "Deir ez-Zor"],
  ["الرقة", "Raqqa"], ["الحسكة", "Al-Hasakah"], ["درعا", "Daraa"],
  ["السويداء", "As-Suwayda"], ["القنيطرة", "Quneitra"]
]
cities.each { |ar, en| City.find_or_create_by!(name_ar: ar) { |c| c.name_en = en } }
puts "✅ Cities: #{City.count}"

# Plans
plans = [
  {
    name: "Free", name_ar: "المجانية", slug: "free",
    price_syp: 0, price_usd: 0,
    max_listings: 20, duration_days: 0,
    features: "حتى 20 إعلان\nظهور أساسي\nدعم عبر البريد",
    active: true, position: 1
  },
  {
    name: "Basic", name_ar: "الأساسية", slug: "basic",
    price_syp: 100_000, price_usd: 15,
    max_listings: 100, duration_days: 30,
    features: "حتى 100 إعلان\nظهور أولوي\nدعم عبر واتساب\nشارات مميزة",
    active: true, position: 2
  },
  {
    name: "Pro", name_ar: "الاحترافية", slug: "pro",
    price_syp: 250_000, price_usd: 35,
    max_listings: 500, duration_days: 30,
    features: "حتى 500 إعلان\nظهور مميز\nدعم أولوي\nشعار موثّق\nتقارير متقدمة",
    active: true, position: 3
  },
  {
    name: "Enterprise", name_ar: "الشركات", slug: "enterprise",
    price_syp: 500_000, price_usd: 70,
    max_listings: 0, duration_days: 30,
    features: "إعلانات غير محدودة\nأولوية قصوى\nمدير حساب\nتكامل API\nشارة ذهبية",
    active: true, position: 4
  }
]
plans.each do |attrs|
  Plan.find_or_create_by!(slug: attrs[:slug]) { |p| p.assign_attributes(attrs) }
end
puts "✅ Plans: #{Plan.count}"

# Admin
admin = User.find_or_initialize_by(email: "admin@syria-agencies.sy")
if admin.new_record?
  admin.assign_attributes(
    password: "Admin123!",
    password_confirmation: "Admin123!",
    full_name: "مدير المنصة",
    phone: "0900000001",
    role: :buyer,
    admin: true
  )
  admin.save!
  puts "✅ Admin: admin@syria-agencies.sy / Admin123!"
else
  admin.update(admin: true)
  puts "ℹ️ Admin already exists"
end
