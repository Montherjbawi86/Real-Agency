class CreateAgencies < ActiveRecord::Migration[7.2]
  def change
    create_table :agencies do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :kind
      t.string :phone
      t.string :whatsapp
      t.string :address
      t.references :city, null: false, foreign_key: true
      t.text :description

      t.timestamps
    end
  end
end
