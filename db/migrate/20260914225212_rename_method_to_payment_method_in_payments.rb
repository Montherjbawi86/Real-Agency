class RenameMethodToPaymentMethodInPayments < ActiveRecord::Migration[7.2]
  def change
    if column_exists?(:payments, :method)
      rename_column :payments, :method, :payment_method
    elsif !column_exists?(:payments, :payment_method)
      add_column :payments, :payment_method, :integer, default: 0
    end
  end
end
