class CreatePayments < ActiveRecord::Migration[7.2]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :contract, null: false, foreign_key: true
      t.references :tenant, null: false, foreign_key: true
      t.decimal :amount
      t.string :currency
      t.date :due_on
      t.date :paid_on
      t.integer :method
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
