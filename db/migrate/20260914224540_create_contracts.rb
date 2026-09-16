class CreateContracts < ActiveRecord::Migration[7.2]
  def change
    create_table :contracts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :property, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.decimal :amount
      t.string :currency
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
