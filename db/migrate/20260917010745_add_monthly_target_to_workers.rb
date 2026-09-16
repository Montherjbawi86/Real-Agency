class AddMonthlyTargetToWorkers < ActiveRecord::Migration[7.2]
  def change
    add_column :workers, :monthly_target, :decimal, precision: 12, scale: 2
  end
end
