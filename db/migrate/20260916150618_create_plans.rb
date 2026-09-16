class CreatePlans < ActiveRecord::Migration[7.2]
  def change
    create_table :plans do |t|
      t.string :name
      t.string :name_ar
      t.string :slug
      t.decimal :price_syp
      t.decimal :price_usd
      t.integer :max_listings
      t.integer :duration_days
      t.text :features
      t.boolean :active
      t.integer :position

      t.timestamps
    end
  end
end
