class CreateProperties < ActiveRecord::Migration[7.2]
  def change
    create_table :properties do |t|
      t.references :user, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :property_type
      t.integer :listing_type
      t.decimal :price
      t.string :currency
      t.integer :size
      t.integer :floor
      t.integer :total_floors
      t.integer :rooms
      t.integer :bathrooms
      t.string :address
      t.integer :status

      t.timestamps
    end
  end
end
