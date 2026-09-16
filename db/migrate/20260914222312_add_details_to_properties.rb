class AddDetailsToProperties < ActiveRecord::Migration[7.2]
  def change
    add_column :properties, :has_elevator, :boolean
    add_column :properties, :has_parking, :boolean
    add_column :properties, :has_garden, :boolean
    add_column :properties, :has_pool, :boolean
    add_column :properties, :has_balcony, :boolean
    add_column :properties, :furnished, :boolean
    add_column :properties, :has_water_well, :boolean
    add_column :properties, :has_solar_energy, :boolean
    add_column :properties, :has_generator, :boolean
    add_column :properties, :has_internet, :boolean
    add_column :properties, :has_security, :boolean
    add_column :properties, :has_central_heating, :boolean
    add_column :properties, :has_ac, :boolean
    add_column :properties, :latitude, :decimal
    add_column :properties, :longitude, :decimal
  end
end
