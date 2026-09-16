class CreatePaymentRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :payment_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscription, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.decimal :amount
      t.string :currency
      t.integer :payment_method
      t.string :reference_number
      t.date :transfer_date
      t.string :sender_name
      t.string :sender_phone
      t.integer :status
      t.text :admin_notes
      t.datetime :processed_at
      t.integer :processed_by

      t.timestamps
    end
  end
end
