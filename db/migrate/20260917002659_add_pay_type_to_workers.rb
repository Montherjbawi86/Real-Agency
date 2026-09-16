class AddPayTypeToWorkers < ActiveRecord::Migration[7.2]
  def change
    add_column :workers, :pay_type, :integer, default: 0, null: false
    add_column :workers, :hourly_rate, :decimal, precision: 12, scale: 2
    add_column :workers, :daily_rate,  :decimal, precision: 12, scale: 2
    add_column :workers, :overtime_multiplier, :decimal, precision: 3, scale: 2, default: 1.5
    add_column :workers, :working_hours_per_day, :integer, default: 8
    add_column :workers, :working_days_per_month, :integer, default: 26
    add_column :workers, :national_id, :string
    add_column :workers, :address, :string
    add_column :workers, :birth_date, :date
    add_column :workers, :emergency_contact, :string
    add_column :workers, :emergency_phone, :string
  end
end
