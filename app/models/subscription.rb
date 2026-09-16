class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  has_one :payment_request, dependent: :nullify

  enum :status, {
    pending:  0,   # بانتظار الموافقة
    active:   1,   # نشط
    expired:  2,   # منتهي
    cancelled: 3,  # ملغى
    rejected: 4    # مرفوض
  }, default: :pending

  validates :user_id, presence: true
  validates :plan_id, presence: true

  scope :active_now, -> { where(status: :active).where("ends_on IS NULL OR ends_on >= ?", Date.current) }
  scope :recent, -> { order(created_at: :desc) }

  # Activate this subscription and expire older ones
  def activate!
    transaction do
      user.subscriptions.where(status: :active).where.not(id: id).update_all(status: :expired)
      update!(status: :active, starts_on: starts_on || Date.current)
    end
  end

  def active_now?
    active? && (ends_on.nil? || ends_on >= Date.current)
  end

  def listings_remaining
    return nil if plan.unlimited?
    plan.max_listings - user.listings_count
  end

  def status_ar
    { pending: "بانتظار الموافقة", active: "نشط", expired: "منتهي",
      cancelled: "ملغى", rejected: "مرفوض" }[status.to_sym]
  end

  def status_badge_class
    { pending: "badge-yellow", active: "badge-green", expired: "badge-gray",
      cancelled: "badge-gray", rejected: "badge-red" }[status.to_sym]
  end

  def expires_soon?
    active_now? && ends_on.present? && ends_on <= 7.days.from_now.to_date
  end
end
