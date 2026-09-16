class Building < ApplicationRecord
  belongs_to :user
  belongs_to :city

  has_many :properties, dependent: :nullify
  has_one_attached :cover_image
  has_many_attached :images

  enum :status, {
    under_construction: 0,  # قيد الإنشاء
    ready: 1,               # جاهز
    operating: 2,           # قيد التشغيل
    archived: 3             # مؤرشف
  }, default: :ready

  validates :name, presence: true, length: { minimum: 3, maximum: 150 }
  validates :city_id, presence: true

  scope :recent, -> { order(created_at: :desc) }

  # ---------- Counts ----------
  def total_units
    properties.count
  end

  def units_by_status
    properties.group(:status).count
  end

  def rented_units
    properties.rented.count
  end

  def sold_units
    properties.sold.count
  end

  def available_units
    properties.published.count
  end

  def occupied_units
    rented_units + sold_units
  end

  def occupancy_percent
    return 0 if total_units.zero?
    (occupied_units.to_f / total_units * 100).round
  end

  # ---------- Payment aggregates ----------
  def total_contract_value
    Contract.where(property_id: property_ids).sum(:amount) || 0
  end

  def total_paid
    Payment.joins(:contract)
           .where(contracts: { property_id: property_ids }, status: :paid)
           .sum(:amount) || 0
  end

  def total_remaining
    total_contract_value - total_paid
  end

  def status_ar
    { under_construction: "قيد الإنشاء", ready: "جاهز",
      operating: "قيد التشغيل", archived: "مؤرشف" }[status.to_sym]
  end

  def status_badge_class
    { under_construction: "badge-yellow", ready: "badge-blue",
      operating: "badge-green", archived: "badge-gray" }[status.to_sym]
  end
end
