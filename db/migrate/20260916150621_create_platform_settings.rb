class CreatePlatformSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :platform_settings do |t|
      t.string :key
      t.text :value

      t.timestamps
    end
  end
end
