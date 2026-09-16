class SocialPostBuilder
  # -------- PROPERTY --------
  def self.for_property(property, platform: :facebook, host: "localhost:3000")
    url    = "https://#{host}/properties/#{property.id}"
    type   = property.property_type_ar
    offer  = property.listing_type_ar
    price  = "#{helper.number_with_delimiter(property.price.to_i)} #{property.currency}"
    city   = property.city&.name_ar
    addr   = property.address
    size   = "#{property.size} م²" if property.size.present?
    rooms  = "#{property.rooms} غرف" if property.rooms.to_i > 0
    baths  = "#{property.bathrooms} حمامات" if property.bathrooms.to_i > 0
    floor  = "الطابق #{property.floor}/#{property.total_floors}" if property.floor.present?
    build  = property.building&.name
    unit   = property.unit_number
    amenities = property.active_amenities.values.first(6).join(" • ")

    case platform.to_sym
    when :facebook, :instagram, :telegram, :whatsapp, :x
      lines = []
      lines << "🏢 #{type} #{offer}"
      lines << "📍 #{city}#{" — #{addr}" if addr.present?}"
      lines << "🏗️ #{build} — وحدة #{unit}" if build.present? && unit.present?
      lines << ""
      lines << "📐 المساحة: #{size}" if size
      lines << "🛏️ الغرف: #{rooms}" if rooms
      lines << "🚿 الحمامات: #{baths}" if baths
      lines << "🏗️ #{floor}" if floor
      lines << ""
      lines << "💰 السعر: #{price}"
      lines << ""
      lines << "✨ #{amenities}" if amenities.present?
      lines << ""
      lines << "📞 للتواصل والاستفسار:"
      lines << "👤 #{property.user.display_name}"
      lines << "☎️ #{property.user.phone}" if property.user.phone.present?
      lines << ""
      lines << "🔗 التفاصيل الكاملة:"
      lines << url
      lines << ""
      lines << "#عقارات_سوريا #عقارات_#{city} ##{offer.gsub('ل', '')} #سوريا_العقارات"
      lines.join("\n")

    when :tiktok
      "#{type} #{offer} في #{city} — #{size || ''} — #{price}. #{url} #عقارات #سوريا"
    end
  end

  # -------- CAR --------
  def self.for_car(car, platform: :facebook, host: "localhost:3000")
    url   = "https://#{host}/cars/#{car.id}"
    name  = "#{car.brand} #{car.car_model} (#{car.year})"
    offer = car.rented? ? "للإيجار" : (car.sold? ? "مُباعة" : "للبيع")
    price = "#{helper.number_with_delimiter(car.price.to_i)} #{car.currency}"
    city  = car.city&.name_ar
    km    = "#{helper.number_with_delimiter(car.mileage.to_i)} كم"

    case platform.to_sym
    when :facebook, :instagram, :telegram, :whatsapp, :x
      lines = []
      lines << "🚗 #{name}"
      lines << "💰 #{offer} — #{price}"
      lines << "📍 #{city}"
      lines << ""
      lines << "🔧 المواصفات:"
      lines << "  • الحالة: #{car.condition_ar}"
      lines << "  • الهيكل: #{car.body_type_ar}"
      lines << "  • الوقود: #{car.fuel_type_ar}"
      lines << "  • ناقل الحركة: #{car.transmission_ar}"
      lines << "  • المسافة: #{km}"
      lines << "  • اللون: #{car.color}" if car.color.present?
      lines << ""
      lines << "📞 للتواصل والاستفسار:"
      lines << "👤 #{car.user.display_name}"
      lines << "☎️ #{car.user.phone}" if car.user.phone.present?
      lines << ""
      lines << "🔗 التفاصيل الكاملة:"
      lines << url
      lines << ""
      lines << "#سيارات #سيارات_سوريا #سيارات_#{city} ##{car.brand} #سوريا_للسيارات"
      lines.join("\n")

    when :tiktok
      "#{name} — #{car.condition_ar} — #{km} — #{price} في #{city}. #{url} #سيارات #سوريا"
    end
  end

  def self.helper
    ActionController::Base.helpers
  end
end
