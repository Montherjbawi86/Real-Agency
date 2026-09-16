class AddCarAndCustomerToContracts < ActiveRecord::Migration[7.2]
  def change
    add_reference :contracts, :car,      foreign_key: true, null: true
    add_reference :contracts, :customer, foreign_key: true, null: true
    add_column    :contracts, :kind, :integer, default: 0, null: false
  end
end
