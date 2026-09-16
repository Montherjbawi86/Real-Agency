class PaymentRequest < ApplicationRecord
  belongs_to :user
  belongs_to :subscription
  belongs_to :plan
  belongs_to :processed_by_user, class_name: "User", foreign_key: :processed_by, optional: true

  has_one_attached :proof_image

  enum :status, {
    pending:  0,   # بانتظار المراجعة
    approved: 1,   # تم القبول
    rejected: 2,   # مرفوض
    cancelled: 3   # ملغى
  }, default: :pending

  enum :payment_method, {
    bank_transfer: 0,   # حوالة بنكية
    sham_cash:     1,   # شام كاش
    haram:         2,   # هرم
    cash_delivery: 3,   # تسليم نقدي
    other:         4
  }, default: :bank_transfer, prefix: :via

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, inclusion: { in: %w[SYP USD] }
  validates :proof_image, presence: true, on: :create

  scope :pending,  -> { where(status: :pending).order(created_at: :desc) }
  scope :recent,   -> { order(created_at: :desc) }

  def payment_method_ar
    { bank_transfer: "حوالة بنكية", sham_cash: "شام كاش",
      haram: "هرم", cash_delivery: "تسليم نقدي", other: "أخرى" }[payment_method.to_sym]
  end

  def status_ar
    { pending: "بانتظار المراجعة", approved: "تم القبول",
      rejected: "مرفوض", cancelled: "ملغى" }[status.to_sym]
  end

  def status_badge_class
    { pending: "badge-yellow", approved: "badge-green",
      rejected: "badge-red", cancelled: "badge-gray" }[status.to_sym]
  end

  # Called by admin
  def approve!(admin_user, notes: nil)
    transaction do
      update!(
        status: :approved,
        admin_notes: notes,
        processed_at: Time.current,
        processed_by: admin_user.id
      )
      subscription.activate!
      # Set end date based on plan duration
      if plan.duration_days.present? && plan.duration_days > 0
        subscription.update!(ends_on: Date.current + plan.duration_days.days)
      end
    end
  end

  def reject!(admin_user, notes: nil)
    update!(
      status: :rejected,
      admin_notes: notes,
      processed_at: Time.current,
      processed_by: admin_user.id
    )
    subscription.update!(status: :rejected)
  end
end
