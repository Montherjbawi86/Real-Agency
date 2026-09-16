class AddRentalFieldsToContracts < ActiveRecord::Migration[7.2]
  def change
    add_column :contracts, :daily_rate,     :decimal, precision: 12, scale: 2
    add_column :contracts, :days,           :integer
    add_column :contracts, :start_odometer, :integer
    add_column :contracts, :end_odometer,   :integer
  end
end
