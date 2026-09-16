class Worker < ApplicationRecord
  belongs_to :user

  has_many :worker_payments,    dependent: :destroy
  has_many :attendance_records, dependent: :destroy
  has_many :worker_holidays,    dependent: :destroy
  has_many :salary_advances,    dependent: :destroy

  enum :pay_type, {
    monthly: 0,
    daily:   1,
    hourly:  2,
    project: 3
  }, default: :monthly

  validates :full_name, presence: true
  validates :currency, inclusion: { in: %w[SYP USD] }
  validate  :rate_must_be_present

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :recent,   -> { order(created_at: :desc) }

  # ============================================================
  # DISPLAY
  # ============================================================
  def pay_type_ar
    { monthly: "شهري", daily: "يومي", hourly: "بالساعة", project: "بالمشروع" }[pay_type.to_sym]
  end

  def position_ar
    position.presence || "—"
  end

  # ============================================================
  # RATES — single source per pay type
  # ============================================================

  # What "the rate" is for the current pay type
  def primary_rate
    case pay_type.to_sym
    when :monthly, :project then monthly_salary.to_d
    when :daily            then daily_rate.to_d
    when :hourly           then hourly_rate.to_d
    end
  end

  def rate_label
    case pay_type.to_sym
    when :monthly, :project then "#{primary_rate} / شهر"
    when :daily             then "#{primary_rate} / يوم"
    when :hourly            then "#{primary_rate} / ساعة"
    end
  end

  # ============================================================
  # SALARY CALCULATION
  # ============================================================

  # Base monthly salary (before overtime, advances)
  def calculated_salary_for(date = Date.current)
    case pay_type.to_sym
    when :monthly, :project
      monthly_salary.to_d

    when :daily
      rate = daily_rate.to_d
      days = days_present(date)
      days = (working_days_per_month || 26) if days.zero?
      days * rate

    when :hourly
      rate = hourly_rate.to_d
      hours = hours_worked(date)
      hours = ((working_hours_per_day || 8) * (working_days_per_month || 26)) if hours.zero?
      hours * rate
    end
  end

  def expected_monthly_salary
    case pay_type.to_sym
    when :monthly, :project
      monthly_salary.to_d
    when :daily
      daily_rate.to_d * (working_days_per_month || 26)
    when :hourly
      hourly_rate.to_d * (working_hours_per_day || 8) * (working_days_per_month || 26)
    end
  end

  # ============================================================
  # HOURS / ATTENDANCE
  # ============================================================
  def hours_worked(date = Date.current)
    attendance_records.in_month(date).sum(:total_hours).to_f
  end

  def overtime_hours(date = Date.current)
    attendance_records.in_month(date).sum(:overtime_hours).to_f
  end

  def days_present(date = Date.current)
    attendance_records.in_month(date).present.count
  end

  def days_absent(date = Date.current)
    attendance_records.in_month(date).absent.count
  end

  def paid_holidays(date = Date.current)
    worker_holidays.in_month(date).paid_holidays.count
  end

  # ============================================================
  # OVERTIME
  # ============================================================
  def overtime_pay(date = Date.current)
    ot_hours = overtime_hours(date)
    return 0.to_d if ot_hours.zero?

    rate = overtime_hourly_rate
    return 0.to_d if rate.zero?

    ot_hours * rate * (overtime_multiplier || 1.5).to_d
  end

  # For overtime, we need an hourly rate regardless of pay type
  def overtime_hourly_rate
    case pay_type.to_sym
    when :hourly
      hourly_rate.to_d
    when :daily
      # Convert daily → hourly
      (daily_rate.to_d / (working_hours_per_day || 8))
    when :monthly, :project
      # Convert monthly → hourly
      hours = (working_hours_per_day || 8) * (working_days_per_month || 26)
      hours > 0 ? (monthly_salary.to_d / hours) : 0.to_d
    end
  end

  # ============================================================
  # PAYMENTS / ADVANCES
  # ============================================================
  def advances_total(date = Date.current)
    salary_advances.in_month(date).sum(:amount).to_d
  end

  def paid_for_month(date = Date.current)
    worker_payments
      .where(currency: currency)
      .where(for_month: date.beginning_of_month..date.end_of_month)
      .sum(:amount) || 0
  end

  def net_salary_for(date = Date.current)
    calculated_salary_for(date) + overtime_pay(date) - advances_total(date)
  end

  def remaining_for_month(date = Date.current)
    net_salary_for(date) - paid_for_month(date)
  end

  def month_fully_paid?(date = Date.current)
    remaining_for_month(date).abs < 1  # treat close to 0 as fully paid
  end

  def current_month_status_ar
    rem = remaining_for_month
    return "دفع زائد"      if rem < -1
    return "مدفوع بالكامل" if rem.abs <= 1
    return "مدفوع جزئياً"  if paid_for_month > 0
    "لم يُدفع بعد"
  end

  def current_month_badge_class
    rem = remaining_for_month
    return "badge-amber"  if rem < -1
    return "badge-green"  if rem.abs <= 1
    return "badge-yellow" if paid_for_month > 0
    "badge-red"
  end

  def total_paid
    worker_payments.where(currency: currency).sum(:amount) || 0
  end

  def total_advances
    salary_advances.sum(:amount) || 0
  end

  private

  def rate_must_be_present
    case pay_type&.to_sym
    when :monthly, :project
      errors.add(:monthly_salary, "الراتب الشهري مطلوب") if monthly_salary.to_d.zero?
    when :daily
      errors.add(:daily_rate, "الأجرة اليومية مطلوبة") if daily_rate.to_d.zero?
    when :hourly
      errors.add(:hourly_rate, "أجرة الساعة مطلوبة") if hourly_rate.to_d.zero?
    end
  end
end
