class Car < ApplicationRecord
  belongs_to :user
  belongs_to :city
  belongs_to :agency, optional: true

  has_one_attached :cover_image
  has_many_attached :images
  has_many :contracts,    dependent: :nullify
  has_many :maintenances, as: :maintainable, dependent: :destroy

  enum :fuel_type, { petrol: 0, diesel: 1, hybrid: 2, electric: 3, gas: 4 }, default: :petrol
  enum :transmission, { manual: 0, automatic: 1 }, default: :manual
  enum :condition, { new_car: 0, used: 1, certified: 2 }, default: :used
  enum :body_type, {
    sedan: 0, suv: 1, hatchback: 2, pickup: 3,
    van: 4, coupe: 5, convertible: 6, wagon: 7
  }, default: :sedan
  enum :status, { draft: 0, published: 1, rented: 2, sold: 3 }, default: :draft

  validates :title, presence: true, length: { minimum: 5, maximum: 150 }
  validates :description, presence: true, length: { minimum: 20 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :brand, presence: true
  validates :car_model, presence: true
  validates :year, presence: true, numericality: { greater_than: 1950, less_than_or_equal_to: ->(_) { Date.current.year + 1 } }
  validates :currency, inclusion: { in: %w[SYP USD] }

  scope :published, -> { where(status: :published) }
  scope :recent,    -> { order(created_at: :desc) }
  scope :rented,    -> { where(status: :rented) }
  scope :sold,      -> { where(status: :sold) }

  FEATURES = {
    has_ac: "تكييف", has_airbags: "وسائد هوائية", has_abs: "نظام ABS",
    has_sunroof: "فتحة سقف", has_navigation: "نظام ملاحة", has_bluetooth: "بلوتوث",
    has_camera: "كاميرا خلفية", has_leather_seats: "مقاعد جلد",
    has_alloy_wheels: "جنوط ألمنيوم", has_cruise_control: "مثبت سرعة",
    has_parking_sensors: "حساسات ركن", has_power_windows: "نوافذ كهربائية",
    has_central_lock: "قفل مركزي", has_heated_seats: "مقاعد مدفأة"
  }.freeze

  def active_features
    FEATURES.select { |k, _| public_send(k) }
  end

  def fuel_type_ar
    { petrol: "بنزين", diesel: "ديزل", hybrid: "هجين", electric: "كهربائي", gas: "غاز" }[fuel_type.to_sym]
  end
  def transmission_ar = manual? ? "عادي" : "أوتوماتيك"
  def condition_ar
    { new_car: "جديد", used: "مستعمل", certified: "معتمد" }[condition.to_sym]
  end
  def body_type_ar
    { sedan: "سيدان", suv: "دفع رباعي", hatchback: "هاتشباك", pickup: "بيك أب",
      van: "فان", coupe: "كوبيه", convertible: "مكشوفة", wagon: "ستيشن" }[body_type.to_sym]
  end
  def status_ar
    { draft: "مسودة", published: "منشور", rented: "مؤجّر", sold: "مُباع" }[status.to_sym]
  end

  def select_label
    formatted_price = ActionController::Base.helpers.number_with_delimiter(price.to_i)
    "#{brand} #{car_model} (#{year}) — #{formatted_price} #{currency} [#{status_ar}]"
  end

  # ---------- Payment tracking ----------
  def total_paid
    Payment.joins(:contract).where(contracts: { car_id: id }, status: :paid).sum(:amount) || 0
  end
  def total_pending
    Payment.joins(:contract).where(contracts: { car_id: id }, status: :pending).sum(:amount) || 0
  end
  def total_contract_value
    contracts.sum(:amount) || 0
  end
  def total_remaining
    total_contract_value - total_paid
  end

  # ---------- YouTube ----------
  def youtube_id
    return nil if youtube_url.blank?
    youtube_url[/(?:youtu\.be\/|v=|embed\/|shorts\/)([\w-]{11})/, 1]
  end

  def youtube_embed_url
    return nil unless youtube_id
    "https://www.youtube.com/embed/#{youtube_id}"
  end

  # ---------- Share ----------
  def share_url(request_host)
    "https://#{request_host}/cars/#{id}"
  end

  def share_text
    "#{brand} #{car_model} (#{year}) — #{number_with_delimiter(price)} #{currency} — #{city&.name_ar}"
  end

  private

  def number_with_delimiter(n)
    ActionController::Base.helpers.number_with_delimiter(n)
  end
  def can_be_published?
    user.can_add_listing? || published?
  end

end
