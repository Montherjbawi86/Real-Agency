class CreateWorkerHolidays < ActiveRecord::Migration[7.2]
  def change
    create_table :worker_holidays do |t|
      t.references :user, null: false, foreign_key: true
      t.references :worker, null: false, foreign_key: true
      t.date :holiday_date
      t.integer :holiday_type
      t.boolean :paid
      t.text :notes

      t.timestamps
    end
  end
end
