class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name
      t.string :phone
      t.string :national_id
      t.string :address
      t.text   :notes

      t.timestamps
    end

    add_index :customers, :phone
  end
end
