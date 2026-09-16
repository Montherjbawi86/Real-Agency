class CreateMaintenances < ActiveRecord::Migration[7.2]
  def change
    create_table :maintenances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :maintainable, polymorphic: true, null: false
      t.string  :title
      t.text    :description
      t.decimal :cost, precision: 15, scale: 2
      t.string  :currency, default: "SYP"
      t.date    :performed_on
      t.date    :next_due_on
      t.integer :kind,   default: 9
      t.integer :status, default: 0
      t.text    :parts

      t.timestamps
    end

    add_index :maintenances, :next_due_on
    add_index :maintenances, :status
  end
end
