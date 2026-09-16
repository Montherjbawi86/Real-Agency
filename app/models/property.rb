class Property < ApplicationRecord
  belongs_to :user
  belongs_to :city
  belongs_to :agency,   optional: true
  belongs_to :building, optional: true

  has_one_attached :cover_image
  has_many_attached :images
  has_many :contracts,    dependent: :nullify
  has_many :tenants,      dependent: :destroy
  has_many :maintenances, as: :maintainable, dependent: :destroy

  enum :property_type, {
    apartment: 0, villa: 1, land: 2, shop: 3,
    office: 4, building_unit: 5, warehouse: 6, farm: 7
  }, default: :apartment

  enum :listing_type, { sale: 0, rent: 1 }, default: :sale
  enum :status, { draft: 0, published: 1, rented: 2, sold: 3 }, default: :draft

  validates :title, presence: true, length: { minimum: 5, maximum: 150 }
  validates :description, presence: true, length: { minimum: 20 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :size, presence: true, numericality: { greater_than: 0 }
  validates :currency, inclusion: { in: %w[SYP USD] }

  scope :published, -> { where(status: :published) }
  scope :recent,    -> { order(created_at: :desc) }
  scope :rented,    -> { where(status: :rented) }
  scope :sold,      -> { where(status: :sold) }

  AMENITIES = {
    has_elevator: "مصعد", has_parking: "موقف سيارات", has_garden: "حديقة",
    has_pool: "مسبح", has_balcony: "شرفة", furnished: "مفروش",
    has_water_well: "بئر ماء", has_solar_energy: "طاقة شمسية",
    has_generator: "مولّد كهرباء", has_internet: "إنترنت",
    has_security: "حراسة", has_central_heating: "تدفئة مركزية",
    has_ac: "تكييف"
  }.freeze

  def active_amenities
    AMENITIES.select { |k, _| public_send(k) }
  end

  def property_type_ar
    { apartment: "شقة", villa: "فيلا", land: "أرض", shop: "محل تجاري",
      office: "مكتب", building_unit: "وحدة بناء", warehouse: "مستودع", farm: "مزرعة" }[property_type.to_sym]
  end

  def listing_type_ar = sale? ? "للبيع" : "للإيجار"
  def status_ar
    { draft: "مسودة", published: "منشور", rented: "مؤجّر", sold: "مُباع" }[status.to_sym]
  end

  # ---------- Payment tracking ----------
  def total_paid
    Payment.joins(:contract).where(contracts: { property_id: id }, status: :paid).sum(:amount) || 0
  end
  def total_pending
    Payment.joins(:contract).where(contracts: { property_id: id }, status: :pending).sum(:amount) || 0
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
    "https://#{request_host}/properties/#{id}"
  end

  def share_text
    "#{title} — #{number_with_delimiter(price)} #{currency} — #{city&.name_ar}"
  end

  private

  def number_with_delimiter(n)
    ActionController::Base.helpers.number_with_delimiter(n)
  end
  def can_be_published?
    user.can_add_listing? || published?
  end

end
