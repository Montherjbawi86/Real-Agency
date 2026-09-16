class AddCustomerToPayments < ActiveRecord::Migration[7.2]
  def change
    add_reference :payments, :customer, foreign_key: true, null: true
  end
end
