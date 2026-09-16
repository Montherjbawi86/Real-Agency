class CreateWorkers < ActiveRecord::Migration[7.2]
  def change
    create_table :workers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :full_name
      t.string :phone
      t.string :position
      t.decimal :salary
      t.string :currency
      t.date :hired_on
      t.boolean :active

      t.timestamps
    end
  end
end
