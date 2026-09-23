class RuleChatbotService
  def initialize(message:, session_id:, property: nil, car: nil)
    @message    = message.to_s.strip
    @session_id = session_id
    @property   = property
    @car        = car
    @normalized = normalize(@message)
  end

  def reply
    save_message("user", @message)
    response = generate_reply
    save_message("assistant", response)
    response
  rescue => e
    Rails.logger.error "RuleChatbot Error: #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.first(5).join("\n")
    "عذراً، حدث خطأ. حاول مرة أخرى."
  end

  private

  def normalize(text)
    text.to_s.downcase
        .gsub(/[أإآ]/, "ا")
        .gsub(/ة/, "ه")
        .gsub(/ى/, "ي")
        .gsub(/[^\p{Arabic}\p{L}\d\s]/, " ")
        .gsub(/\s+/, " ")
        .strip
  end

  def match?(*keywords)
    keywords.any? { |k| @normalized.include?(normalize(k)) }
  end

  def generate_reply
    return greeting_response   if match?("مرحبا", "السلام", "اهلا", "هاي", "hi", "hello")
    return contact_response    if match?("تواصل", "هاتف", "رقم", "اتصل", "واتس", "whatsapp")
    return price_response      if match?("سعر", "كم", "تكلفة", "price", "ثمن")
    return area_response       if match?("مساحة", "متر", "م2")
    return rooms_response      if match?("غرف", "غرفة", "نوم")
    return bathrooms_response  if match?("حمام", "حمامات")
    return floor_response      if match?("طابق", "دور")
    return amenities_response  if match?("مصعد", "موقف", "مسبح", "مزايا", "حديقة", "تدفئة", "مولد", "مفروش", "تكييف", "شرفة")
    return location_response   if match?("عنوان", "مكان", "منطقة", "موقع", "اين")

    if @car
      return car_info_response         if match?("سيارة", "مواصفات", "تفاصيل", "معلومات")
      return car_mileage_response      if match?("مسافة", "كيلومتر", "كم")
      return car_fuel_response         if match?("وقود", "بنزين", "ديزل")
      return car_year_response         if match?("سنة", "موديل", "عام")
      return car_transmission_response if match?("ناقل", "حركة", "اوتوماتيك", "عادي")
    end

    return availability_response     if match?("متوفر", "متاح", "موجود")
    return booking_response          if match?("زيارة", "معاينه", "موعد", "احجز")
    return payment_response          if match?("دفع", "تقسيط", "اقساط", "بنك")
    return register_response         if match?("تسجيل", "حساب", "عضوية")
    return subscribe_response        if match?("اشتراك", "ترقيه", "خطه")
    return how_to_response           if match?("كيف", "طريقة")
    return thanks_response           if match?("شكرا", "مشكور", "thanks")

    return search_properties_response if match?("شقه", "شقق", "فيلا", "بيت", "منزل", "عقار", "عقارات", "ارض", "اراضي")
    return search_cars_response       if match?("سيارات", "سياره", "مركبه", "سيارة")

    fallback_response
  end

  def greeting_response
    if @property
      "أهلاً وسهلاً! 👋 أنا هنا للإجابة على أسئلتك حول: #{@property.title}."
    elsif @car
      "أهلاً! 👋 اسألني أي شيء عن: #{@car.brand} #{@car.car_model} (#{@car.year})."
    else
      "أهلاً وسهلاً! 👋 اسألني عن العقارات، السيارات، الأسعار، أو التواصل مع الوكلاء."
    end
  end

  def contact_response
    target = @property || @car
    if target
      phone = target.user.phone.to_s
      clean = phone.sub(/^0/, "").sub(/^\+963/, "")
      "📞 للتواصل مع الوكيل:\n👤 #{target.user.display_name}\n☎️ #{phone}\n💬 واتساب: https://wa.me/963#{clean}"
    else
      "📞 للتواصل:\n📧 info@syria-agencies.sy\n☎️ +963 11 123 4567"
    end
  end

  def price_response
    if @property
      "💰 سعر #{@property.title}: #{format_price(@property.price)} #{@property.currency} (#{@property.listing_type_ar})."
    elsif @car
      "💰 سعر #{@car.brand} #{@car.car_model}: #{format_price(@car.price)} #{@car.currency}."
    else
      cheapest = Property.published.order(:price).first
      if cheapest
        "💰 الأسعار تبدأ من #{format_price(cheapest.price)} #{cheapest.currency}.\n🔗 /properties"
      else
        "💰 لا توجد عقارات مسعّرة. جرب /properties"
      end
    end
  end

  def area_response
    if @property
      "📐 المساحة: #{@property.size || '—'} م²."
    else
      "📐 فلتر المساحة في /properties"
    end
  end

  def rooms_response
    if @property && @property.rooms.to_i > 0
      "🛏️ عدد الغرف: #{@property.rooms}."
    elsif @property
      "🏠 هذا العقار ليس سكنياً."
    else
      "🛏️ استخدم فلتر الغرف في /properties"
    end
  end

  def bathrooms_response
    @property ? "🚿 عدد الحمامات: #{@property.bathrooms || 0}." : "🚿 يختلف حسب العقار."
  end

  def floor_response
    @property ? "🏗️ الطابق: #{@property.floor || 0} / #{@property.total_floors || 0}." : "🏗️ يختلف."
  end

  def amenities_response
    if @property && @property.active_amenities.any?
      "✨ مزايا #{@property.title}:\n#{@property.active_amenities.values.join('، ')}"
    elsif @car && @car.active_features.any?
      "✨ مزايا السيارة:\n#{@car.active_features.values.join('، ')}"
    else
      "✨ اطلب الميزة بالتحديد (مصعد، موقف، مسبح...)."
    end
  end

  def location_response
    if @property
      "📍 #{@property.city&.name_ar}#{" — #{@property.address}" if @property.address.present?}"
    elsif @car
      "📍 #{@car.city&.name_ar}"
    else
      "📍 اختر المدينة من /properties"
    end
  end

  def car_info_response
    c = @car
    "🚗 #{c.brand} #{c.car_model} (#{c.year})\n" \
    "💰 #{format_price(c.price)} #{c.currency}\n" \
    "🛣️ #{format_price(c.mileage)} كم\n" \
    "⛽ #{c.fuel_type_ar}\n" \
    "⚙️ #{c.transmission_ar}\n" \
    "🔧 #{c.condition_ar}"
  end

  def car_mileage_response = "🛣️ المسافة: #{format_price(@car.mileage)} كم"
  def car_fuel_response    = "⛽ الوقود: #{@car.fuel_type_ar}"
  def car_year_response    = "📅 السنة: #{@car.year}"
  def car_transmission_response = "⚙️ ناقل الحركة: #{@car.transmission_ar}"

  def availability_response
    if @property
      @property.published? ? "✅ نعم، العقار متوفر." : "⏳ غير منشور حالياً."
    elsif @car
      @car.published? ? "✅ نعم، السيارة متوفرة." : "⏳ غير متوفرة."
    else
      "✅ تحقق من حالة كل إعلان."
    end
  end

  def booking_response
    target = @property || @car
    if target
      "📅 للزيارة، تواصل مع الوكيل:\n👤 #{target.user.display_name}\n☎️ #{target.user.phone}"
    else
      "📅 افتح صفحة الإعلان واضغط 'اتصل' أو 'واتساب'."
    end
  end

  def payment_response
    "💳 طرق الدفع: نقداً، شام كاش، حوالة بنكية، هرم.\n🔗 /faq"
  end

  def register_response
    "📝 للتسجيل: /users/sign_up\n• مشترٍ: حساب عادي\n• وكيل: اختر 'وكيل عقارات' أو 'وكيل سيارات'"
  end

  def subscribe_response
    "💎 الخطط:\n• المجانية: 20 إعلان\n• الأساسية: 100\n• الاحترافية: 500\n🔗 /billing/plans"
  end

  def how_to_response
    "📖 أدلة:\n• كيفية الإعلان: /how-to-sell\n• الأسئلة الشائعة: /faq"
  end

  def thanks_response = "العفو! 🌟 هل تحتاج شيئاً آخر؟"

  def fallback_response
    if @property
      "🤔 لم أفهم. اسأل عن: السعر، المساحة، الغرف، المزايا، أو التواصل.\n☎️ #{@property.user.phone}"
    elsif @car
      "🤔 لم أفهم. اسأل عن: السعر، المسافة، الوقود، السنة، أو التواصل."
    else
      "🤔 لم أفهم. جرب:\n• \"شقق في دمشق\"\n• \"سيارات للبيع\"\n• \"كيف أتواصل؟\""
    end
  end

  def search_properties_response
    city = extract_city
    props = Property.published
    props = props.where(city_id: city.id) if city
    props = props.limit(3)

    if props.any?
      lines = ["🏘️ وجدت #{props.count} عقار#{" في #{city.name_ar}" if city}:"]
      props.each { |p| lines << "• #{p.title} — #{format_price(p.price)} #{p.currency}" }
      lines << "\n🔗 /properties"
      lines.join("\n")
    else
      "🔍 لم أجد عقارات مطابقة. جرب /properties"
    end
  end

  def search_cars_response
    cars = Car.published.limit(3)
    if cars.any?
      lines = ["🚗 وجدت #{cars.count} سيارة:"]
      cars.each { |c| lines << "• #{c.brand} #{c.car_model} (#{c.year}) — #{format_price(c.price)} #{c.currency}" }
      lines << "\n🔗 /cars"
      lines.join("\n")
    else
      "🔍 لم أجد سيارات. جرب /cars"
    end
  end

  def extract_city
    City.find { |c| @normalized.include?(normalize(c.name_ar)) }
  end

  def format_price(number)
    return "0" if number.nil?
    number.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\1,').reverse
  rescue
    number.to_s
  end

  def save_message(role, content)
    ChatMessage.create!(
      session_id: @session_id,
      role:       role,
      content:    content
    )
  end
end
