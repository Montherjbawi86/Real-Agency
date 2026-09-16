class AddProfileFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :full_name, :string
    add_column :users, :phone,     :string
    add_column :users, :role,      :integer, null: false, default: 0
    add_index  :users, :phone, unique: true
    add_index  :users, :role
  end
end
