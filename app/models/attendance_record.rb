class AttendanceRecord < ApplicationRecord
  belongs_to :user
  belongs_to :worker

  enum :status, {
    present:  0,   # حاضر
    absent:   1,   # غائب
    late:     2,   # متأخر
    half_day: 3,   # نصف يوم
    leave:    4,   # إجازة
    holiday:  5,   # عطلة رسمية
    sick:     6    # مرض
  }, default: :present

  validates :work_date, presence: true
  validates :work_date, uniqueness: { scope: :worker_id, message: "الحضور مسجل مسبقاً لهذا اليوم" }

  before_save :compute_hours, if: :check_in_and_check_out_present?

  scope :recent,   -> { order(work_date: :desc) }
  scope :in_month, ->(date) { where(work_date: date.beginning_of_month..date.end_of_month) }

  def status_ar
    { present: "حاضر", absent: "غائب", late: "متأخر",
      half_day: "نصف يوم", leave: "إجازة", holiday: "عطلة", sick: "مرض" }[status.to_sym]
  end

  def status_badge_class
    { present: "badge-green", absent: "badge-red", late: "badge-yellow",
      half_day: "badge-yellow", leave: "badge-blue", holiday: "badge-blue",
      sick: "badge-purple" }[status.to_sym]
  end

  private

  def check_in_and_check_out_present?
    check_in.present? && check_out.present?
  end

  def compute_hours
    return unless check_in.present? && check_out.present?

    minutes = (check_out - check_in) / 60.0
    self.total_hours = (minutes / 60.0).round(2)

    # Overtime = hours beyond standard 8h
    standard = worker.working_hours_per_day || 8
    self.overtime_hours = [total_hours - standard, 0].max.round(2)
  end
end
