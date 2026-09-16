class CreateAttendanceRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :attendance_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :worker, null: false, foreign_key: true
      t.date :work_date
      t.time :check_in
      t.time :check_out
      t.decimal :total_hours
      t.decimal :overtime_hours
      t.integer :status
      t.text :notes

      t.timestamps
    end
  end
end
