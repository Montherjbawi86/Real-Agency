class Maintenance < ApplicationRecord
  belongs_to :user
  belongs_to :maintainable, polymorphic: true

  enum :kind, {
    oil_change: 0, tires: 1, brakes: 2, engine: 3, ac_service: 4,
    plumbing: 5, electrical: 6, painting: 7, elevator: 8, general: 9
  }, default: :general

  enum :status, { scheduled: 0, in_progress: 1, completed: 2 }, default: :scheduled

  validates :title, presence: true

  scope :upcoming, -> { where("next_due_on >= ?", Date.current).order(:next_due_on) }
  scope :overdue,  -> { where("next_due_on < ?", Date.current).where.not(status: :completed) }
end
