class MakePropertyIdNullableOnContracts < ActiveRecord::Migration[7.2]
  def change
    change_column_null :contracts, :property_id, true
    change_column_null :contracts, :tenant_id,   true
  end
end
