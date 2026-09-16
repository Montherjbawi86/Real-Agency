class CreateSalaryAdvances < ActiveRecord::Migration[7.2]
  def change
    create_table :salary_advances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :worker, null: false, foreign_key: true
      t.decimal :amount
      t.string :currency
      t.date :advance_date
      t.text :reason
      t.boolean :settled
      t.date :settled_on

      t.timestamps
    end
  end
end
