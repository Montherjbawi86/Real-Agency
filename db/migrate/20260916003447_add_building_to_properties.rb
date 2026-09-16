class AddBuildingToProperties < ActiveRecord::Migration[7.2]
  def change
    add_reference :properties, :building, foreign_key: true, null: true
    add_column    :properties, :unit_number, :string
    add_column    :properties, :unit_label,  :string
  end
end
