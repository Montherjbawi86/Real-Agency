class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :contract
  belongs_to :tenant,   optional: true
  belongs_to :customer, optional: true

  has_one_attached :receipt

  enum :payment_method, { cash: 0, bank: 1, sham_cash: 2, haram: 3, other: 4 }, default: :cash, prefix: :via
  enum :status, { pending: 0, paid: 1, overdue: 2 }, default: :pending

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate  :currency_matches_contract

  scope :unpaid,   -> { where(status: :pending) }
  scope :paid,     -> { where(status: :paid) }
  scope :overdue,  -> { where(status: :pending).where("due_on < ?", Date.current) }
  scope :recent,   -> { order(created_at: :desc) }
  scope :due_soon, -> { where(status: :pending).where("due_on BETWEEN ? AND ?", Date.current, 7.days.from_now) }

  def party = tenant || customer

  def is_overdue?
    pending? && due_on.present? && due_on < Date.current
  end

  def status_ar
    return "متأخرة" if is_overdue?
    return "مدفوعة" if paid?
    "معلقة"
  end

  def status_badge_class
    return "badge-red"    if is_overdue?
    return "badge-green"  if paid?
    "badge-yellow"
  end

  private

  def currency_matches_contract
    return unless contract && currency.present?
    if contract.currency.present? && currency != contract.currency
      errors.add(:currency, "يجب أن تطابق عملة العقد (#{contract.currency})")
    end
  end
end
