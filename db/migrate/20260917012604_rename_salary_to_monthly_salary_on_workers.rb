class RenameSalaryToMonthlySalaryOnWorkers < ActiveRecord::Migration[7.2]
  def change
    # Copy salary → monthly_salary for existing monthly workers
    add_column :workers, :monthly_salary, :decimal, precision: 12, scale: 2, default: 0

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE workers
          SET monthly_salary = salary
          WHERE pay_type = 0  -- monthly
        SQL

        # For hourly workers, derive hourly_rate from salary if missing
        execute <<-SQL
          UPDATE workers
          SET hourly_rate = ROUND(salary / (working_hours_per_day * working_days_per_month), 2)
          WHERE pay_type = 2 AND (hourly_rate IS NULL OR hourly_rate = 0)
            AND salary > 0
            AND working_hours_per_day > 0
            AND working_days_per_month > 0
        SQL

        # For daily workers, derive daily_rate from salary if missing
        execute <<-SQL
          UPDATE workers
          SET daily_rate = ROUND(salary / working_days_per_month, 2)
          WHERE pay_type = 1 AND (daily_rate IS NULL OR daily_rate = 0)
            AND salary > 0
            AND working_days_per_month > 0
        SQL
      end
    end
  end
end
