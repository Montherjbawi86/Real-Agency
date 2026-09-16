class Plan < ApplicationRecord
  has_many :subscriptions, dependent: :restrict_with_error

  validates :name, :name_ar, :slug, presence: true
  validates :slug, uniqueness: true
  validates :price_syp, :price_usd, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true).order(:position) }

  def free?
    slug == "free" || (price_syp.to_d.zero? && price_usd.to_d.zero?)
  end

  def unlimited?
    max_listings.nil? || max_listings.zero?
  end

  def price_for(currency)
    currency.to_s.upcase == "USD" ? price_usd : price_syp
  end

  def max_listings_label
    unlimited? ? "غير محدود" : "#{max_listings} إعلان"
  end

  def duration_label
    return "دائم" if duration_days.nil? || duration_days.zero?
    "#{duration_days} يوم"
  end

  def features_list
    (features || "").split("\n").map(&:strip).reject(&:blank?)
  end
end
