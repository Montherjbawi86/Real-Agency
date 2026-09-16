class WorkerPayment < ApplicationRecord
  belongs_to :user
  belongs_to :worker

  enum :payment_method, {
    cash:        0,
    bank:        1,
    sham_cash:   2,
    haram:       3,
    other:       4
  }, default: :cash, prefix: :via

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :paid_on, presence: true
  validates :currency, inclusion: { in: %w[SYP USD] }

  scope :recent,      -> { order(paid_on: :desc) }
  scope :for_month,   ->(date) { where(for_month: date.beginning_of_month..date.end_of_month) }
  scope :by_currency, ->(cur) { where(currency: cur) }

  def payment_method_ar
    { cash: "نقداً", bank: "بنك", sham_cash: "شام كاش",
      haram: "هرم", other: "أخرى" }[payment_method.to_sym]
  end

  def month_label
    return "—" if for_month.blank?
    I18n.l(for_month, format: "%B %Y") rescue for_month.strftime("%Y-%m")
  end
end
