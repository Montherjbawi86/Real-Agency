class Customer < ApplicationRecord
  belongs_to :user

  has_many :contracts, dependent: :nullify
  has_many :payments,  dependent: :nullify

  validates :full_name, presence: true
  validates :phone, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def select_label
    "#{full_name} — #{phone}"
  end

  def total_paid
    payments.where(status: :paid).sum(:amount)
  end

  def total_pending
    payments.where(status: :pending).sum(:amount)
  end

  def total_overdue
    payments.where(status: :pending).where("due_on < ?", Date.current).sum(:amount)
  end
end
