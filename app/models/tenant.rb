class Tenant < ApplicationRecord
  belongs_to :user
  belongs_to :property

  has_many :contracts, dependent: :nullify
  has_many :payments,  dependent: :nullify

  validates :full_name, presence: true
  validates :phone, presence: true
  validates :rent_amount, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

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
