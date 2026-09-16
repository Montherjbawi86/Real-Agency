class Contract < ApplicationRecord
  belongs_to :user
  belongs_to :property,  optional: true
  belongs_to :car,       optional: true
  belongs_to :tenant,    optional: true
  belongs_to :customer,  optional: true

  has_one_attached :pdf
  has_many :payments, dependent: :destroy

  enum :kind, { rent: 0, sale: 1 }, default: :rent
  enum :status, { draft: 0, active: 1, completed: 2, expired: 3, terminated: 4 }, default: :draft

  validates :start_date, presence: true
  validates :end_date,   presence: true
  validates :amount,     presence: true, numericality: { greater_than: 0 }
  validates :currency,   inclusion: { in: %w[SYP USD] }

  before_validation :calculate_car_rental_amount, if: :car_daily_rental?

  scope :for_properties, -> { where.not(property_id: nil) }
  scope :for_cars,       -> { where.not(car_id: nil) }
  scope :recent,         -> { order(created_at: :desc) }
  scope :active_ones,    -> { where(status: :active) }

  def car_daily_rental?
    car_id.present? && rent? && daily_rate.present?
  end

  def calculate_car_rental_amount
    return unless start_date.present? && end_date.present?
    self.days   = (end_date - start_date).to_i + 1
    self.amount = days * daily_rate.to_d
  end

  # ============================================================
  # PAYMENT TRACKING — currency-aware
  # ============================================================

  # Paid in the SAME currency as the contract
  def paid_amount
    payments.where(status: :paid, currency: currency).sum(:amount) || 0
  end

  # Pending in the SAME currency
  def pending_amount
    payments.where(status: :pending, currency: currency).sum(:amount) || 0
  end

  # Remaining (only same-currency)
  def remaining_amount
    amount.to_d - paid_amount
  end

  def overdue_amount
    payments.where(status: :pending, currency: currency)
            .where("due_on < ?", Date.current).sum(:amount) || 0
  end

  def progress_percent
    return 0 if amount.to_d.zero?
    [(paid_amount / amount.to_d * 100).round, 100].min
  end

  def fully_paid? = remaining_amount <= 0
  def overpaid?   = remaining_amount < 0

  def payment_status_ar
    return "مدفوع بالكامل"  if fully_paid? && !overpaid?
    return "دفع زائد"       if overpaid?
    return "متأخر"          if overdue_amount > 0
    return "جزئي"           if paid_amount > 0
    "لم يُدفع بعد"
  end

  def payment_badge_class
    return "badge-green"  if fully_paid? && !overpaid?
    return "badge-red"    if overpaid? || overdue_amount > 0
    return "badge-yellow" if paid_amount > 0
    "badge-gray"
  end

  # Per-currency breakdown (all payments, both currencies)
  def paid_amount_by_currency
    payments.where(status: :paid).group(:currency).sum(:amount)
  end

  def distance_km
    return nil unless start_odometer.present? && end_odometer.present?
    end_odometer - start_odometer
  end

  def subject; property || car; end
  def party;   tenant || customer; end

  def subject_label
    if property&.building
      "#{property.unit_label.presence || "وحدة #{property.unit_number}"} في #{property.building.name}"
    elsif property
      property.title
    elsif car
      "#{car.brand} #{car.car_model} (#{car.year})"
    else
      "—"
    end
  end

  def subject_type_ar
    return "وحدة بناء" if property&.building
    property_id.present? ? "عقار" : "سيارة"
  end

  def kind_ar = rent? ? "إيجار" : "بيع"
  def status_ar
    { draft: "مسودة", active: "نشط", completed: "مكتمل", expired: "منتهي", terminated: "ملغى" }[status.to_sym]
  end
end
