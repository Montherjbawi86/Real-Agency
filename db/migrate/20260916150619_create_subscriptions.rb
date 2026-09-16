class CreateSubscriptions < ActiveRecord::Migration[7.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :plan, null: false, foreign_key: true
      t.integer :status
      t.date :starts_on
      t.date :ends_on
      t.integer :listings_used
      t.text :notes

      t.timestamps
    end
  end
end
