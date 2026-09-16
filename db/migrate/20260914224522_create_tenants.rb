class CreateTenants < ActiveRecord::Migration[7.2]
  def change
    create_table :tenants do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.string :full_name
      t.string :phone
      t.string :national_id
      t.date :start_date
      t.date :end_date
      t.decimal :rent_amount
      t.string :currency
      t.boolean :active

      t.timestamps
    end
  end
end
