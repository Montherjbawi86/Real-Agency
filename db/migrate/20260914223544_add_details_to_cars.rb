class AddDetailsToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :has_ac, :boolean
    add_column :cars, :has_airbags, :boolean
    add_column :cars, :has_abs, :boolean
    add_column :cars, :has_sunroof, :boolean
    add_column :cars, :has_navigation, :boolean
    add_column :cars, :has_bluetooth, :boolean
    add_column :cars, :has_camera, :boolean
    add_column :cars, :has_leather_seats, :boolean
    add_column :cars, :has_alloy_wheels, :boolean
    add_column :cars, :has_cruise_control, :boolean
    add_column :cars, :has_parking_sensors, :boolean
    add_column :cars, :has_power_windows, :boolean
    add_column :cars, :has_central_lock, :boolean
    add_column :cars, :has_heated_seats, :boolean
    add_column :cars, :latitude, :decimal
    add_column :cars, :longitude, :decimal
  end
end
