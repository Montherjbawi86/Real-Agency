class Agency < ApplicationRecord
  belongs_to :user
  belongs_to :city

  has_one_attached :logo
  has_one_attached :commercial_registry_file
  has_one_attached :license_file
  has_one_attached :tax_file

  enum :kind, { car: 0, property: 1 }

  enum :approval_status, {
    pending:   0,
    approved:  1,
    rejected:  2,
    suspended: 3
  }, default: :pending

  validates :name,  presence: true, length: { minimum: 3, maximum: 150 }
  validates :phone, presence: true
  validates :city_id, presence: true

  scope :verified, -> { where(verified: true) }

  # ============================================================
  # DISPLAY HELPERS
  # ============================================================
  def kind_ar
    car? ? "وكالة سيارات" : "وكالة عقارات"
  end

  def full_address
    [address, city&.name_ar].compact.join(" — ")
  end

  def whatsapp_link
    return nil if whatsapp.blank?
    number = whatsapp.to_s.sub(/^0/, "").sub(/^\+963/, "")
    "https://wa.me/963#{number}"
  end

  def years_in_business
    return nil if founded_on.blank?
    ((Date.current - founded_on) / 365.25).floor
  end

  # ============================================================
  # APPROVAL
  # ============================================================
  def approval_status_ar
    { pending: "بانتظار الموافقة", approved: "موافق عليها",
      rejected: "مرفوضة", suspended: "موقوفة" }[approval_status.to_sym]
  end

  def approval_badge_class
    { pending: "badge-yellow", approved: "badge-green",
      rejected: "badge-red", suspended: "badge-gray" }[approval_status.to_sym]
  end

  def approved?
    approval_status == "approved"
  end

  def pending_approval?
    approval_status == "pending"
  end

  def rejected_or_suspended?
    %w[rejected suspended].include?(approval_status)
  end

  def approve!(admin_user)
    update!(
      approval_status:  :approved,
      approved_at:      Time.current,
      approved_by:      admin_user.id,
      verified:         true,
      verified_at:      Time.current,
      rejection_reason: nil
    )
  end

  def reject!(admin_user, reason: nil)
    update!(
      approval_status:  :rejected,
      approved_by:      admin_user.id,
      rejection_reason: reason,
      verified:         false
    )
  end

  def suspend!(admin_user, reason: nil)
    update!(
      approval_status:  :suspended,
      approved_by:      admin_user.id,
      rejection_reason: reason,
      verified:         false
    )
  end

  # ============================================================
  # COMPLETENESS
  # ============================================================
  def completeness
    checks = {
      "logo"                 => logo.attached?,
      "email"                => email.present?,
      "tax_number"           => tax_number.present?,
      "commercial_registry"  => commercial_registry.present?,
      "commercial_license"   => commercial_license.present?,
      "professional_license" => professional_license.present?,
      "address"              => address.present?,
      "whatsapp"             => whatsapp.present?,
      "description"          => description.present?,
      "authorized_person"    => authorized_person.present?,
      "founded_on"           => founded_on.present?
    }
    filled  = checks.count { |_, v| v }
    total   = checks.size
    percent = (filled.to_f / total * 100).round
    { filled: filled, total: total, percent: percent, missing: checks.reject { |_, v| v }.keys }
  end
end
