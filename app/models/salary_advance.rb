class SalaryAdvance < ApplicationRecord
  belongs_to :user
  belongs_to :worker

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :advance_date, presence: true

  scope :recent,     -> { order(advance_date: :desc) }
  scope :in_month,   ->(date) { where(advance_date: date.beginning_of_month..date.end_of_month) }
  scope :unsettled,  -> { where(settled: false) }
end
