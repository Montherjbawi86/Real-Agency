class MakeTenantIdNullableOnPayments < ActiveRecord::Migration[7.2]
  def change
    change_column_null :payments, :tenant_id, true
  end
end
