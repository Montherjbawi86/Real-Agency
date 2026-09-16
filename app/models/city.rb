class City < ApplicationRecord
  has_many :properties, dependent: :restrict_with_error

  validates :name_ar, presence: true, uniqueness: true

  def to_s = name_ar
end
