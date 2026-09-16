class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { buyer: 0, car_agent: 1, property_agent: 2 }, default: :buyer

  has_one  :agency, dependent: :destroy
  has_many :buildings,      dependent: :destroy
  has_many :properties,     dependent: :destroy
  has_many :cars,           dependent: :destroy
  has_many :workers,        dependent: :destroy
  has_many :worker_payments,    dependent: :destroy
  has_many :attendance_records, dependent: :destroy
  has_many :worker_holidays,    dependent: :destroy
  has_many :salary_advances,    dependent: :destroy
  has_many :tenants,        dependent: :destroy
  has_many :customers,      dependent: :destroy
  has_many :contracts,      dependent: :destroy
  has_many :payments,       dependent: :destroy
  has_many :maintenances,   dependent: :destroy
  has_many :subscriptions,  dependent: :destroy
  has_many :payment_requests, dependent: :destroy

  validates :full_name, presence: true
  validates :phone, presence: true,
                    format: { with: /\A(\+?963|0)?9\d{8}\z/, message: "رقم هاتف سوري غير صالح" },
                    uniqueness: { case_sensitive: false, message: "رقم الهاتف مستخدم بالفعل" }

  before_validation :normalize_phone
  after_create :assign_free_plan, if: :agent?

  scope :agents, -> { where(role: [:car_agent, :property_agent]) }
  scope :buyers, -> { where(role: :buyer) }

  def agent? = car_agent? || property_agent?
  def admin? = admin == true
  def staff? = admin?

  def display_name = full_name.presence || email.split("@").first

  # ---------- Listings count ----------
  def listings_count
    car_agent? ? cars.count : properties.count
  end

  # ---------- Subscription ----------
  def current_subscription
    sub = subscriptions.active_now.order(created_at: :desc).first
    return sub if sub

    # Auto-heal: create a free subscription if missing
    return nil unless agent?

    free_plan = Plan.find_by(slug: "free")
    return nil unless free_plan

    subscriptions.create!(
      plan:      free_plan,
      status:    :active,
      starts_on: Date.current,
      ends_on:   nil
    )
  rescue => e
    Rails.logger.error "[current_subscription] Auto-heal failed for #{email}: #{e.message}"
    nil
  end

  def current_plan
    current_subscription&.plan || Plan.find_by(slug: "free")
  end

  # Can the user add a new listing?
  def can_add_listing?
    return false unless agent?

    plan = current_plan
    return false unless plan

    # Unlimited plan (max_listings = 0 or nil)
    return true if plan.max_listings.to_i.zero?

    # Otherwise: check subscription active + under limit
    sub = current_subscription
    return false unless sub&.active_now?

    listings_count < plan.max_listings
  end

  # How many listings remaining (always returns an Integer)
  def listings_remaining
    plan = current_plan
    return 999_999 if plan.nil?
    return 999_999 if plan.max_listings.to_i.zero?

    sub = current_subscription
    return 0 unless sub&.active_now?

    [plan.max_listings - listings_count, 0].max
  end

  # Is the plan unlimited?
  def unlimited_plan?
    current_plan&.max_listings.to_i.zero?
  end

  def has_active_subscription?
    current_subscription.present?
  end

  def latest_pending_request
    payment_requests.where(status: :pending).order(created_at: :desc).first
  end

  private

  def normalize_phone
    return if phone.blank?
    self.phone = phone.to_s.gsub(/[\s\-\(\)]/, "")
  end

  def assign_free_plan
    # Don't double-assign
    return if subscriptions.active_now.exists?

    free_plan = Plan.find_by(slug: "free")
    unless free_plan
      Rails.logger.warn "[assign_free_plan] Free plan not found for #{email}"
      return
    end

    subscriptions.create!(
      plan:      free_plan,
      status:    :active,
      starts_on: Date.current,
      ends_on:   nil
    )
  rescue => e
    Rails.logger.error "[assign_free_plan] Failed for #{email}: #{e.message}"
  end
  # Is the agent's agency approved?
  def agent_approved?
    return true unless agent?
    agency.present? && agency.approved?
  end

  # Can the agent publish listings?
  def can_publish_listings?
    return false unless agent?
    return false unless agent_approved?
    can_add_listing?
  end

end
