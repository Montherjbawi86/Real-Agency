class CreateWorkerPayments < ActiveRecord::Migration[7.2]
  def change
    create_table :worker_payments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :worker, null: false, foreign_key: true
      t.decimal :amount
      t.string :currency
      t.date :paid_on
      t.date :for_month
      t.integer :payment_method
      t.text :notes

      t.timestamps
    end
  end
end
