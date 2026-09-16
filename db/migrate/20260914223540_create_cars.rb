class CreateCars < ActiveRecord::Migration[7.2]
  def change
    create_table :cars do |t|
      t.references :user, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.string :brand
      t.string :car_model
      t.integer :year
      t.decimal :price
      t.string :currency
      t.integer :mileage
      t.integer :fuel_type
      t.integer :transmission
      t.integer :condition
      t.integer :body_type
      t.string :color
      t.integer :doors
      t.integer :seats
      t.integer :engine_size
      t.integer :status

      t.timestamps
    end
  end
end
