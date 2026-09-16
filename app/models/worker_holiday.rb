class WorkerHoliday < ApplicationRecord
  belongs_to :user
  belongs_to :worker

  enum :holiday_type, {
    official:    0,   # عطلة رسمية
    vacation:    1,   # إجازة سنوية
    sick:        2,   # إجازة مرضية
    personal:    3,   # إجازة شخصية
    emergency:   4,   # ظرف طارئ
    unpaid:      5    # إجازة بدون راتب
  }, default: :personal

  validates :holiday_date, presence: true

  scope :recent,       -> { order(holiday_date: :desc) }
  scope :in_month,     ->(date) { where(holiday_date: date.beginning_of_month..date.end_of_month) }
  scope :paid_holidays, -> { where(paid: true) }

  def holiday_type_ar
    { official: "عطلة رسمية", vacation: "إجازة سنوية",
      sick: "إجازة مرضية", personal: "إجازة شخصية",
      emergency: "ظرف طارئ", unpaid: "بدون راتب" }[holiday_type.to_sym]
  end

  def badge_class
    return "badge-green" if paid
    "badge-gray"
  end
end
