class CreateBuildings < ActiveRecord::Migration[7.2]
  def change
    create_table :buildings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :city, null: false, foreign_key: true
      t.string :name
      t.string :address
      t.integer :floors_count
      t.integer :units_per_floor
      t.integer :year_built
      t.text :description
      t.integer :status

      t.timestamps
    end
  end
end
