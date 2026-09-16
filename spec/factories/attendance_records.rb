FactoryBot.define do
  factory :attendance_record do
    user { nil }
    worker { nil }
    work_date { "2026-09-17" }
    check_in { "2026-09-17 00:27:25" }
    check_out { "2026-09-17 00:27:25" }
    total_hours { "9.99" }
    overtime_hours { "9.99" }
    status { 1 }
    notes { "MyText" }
  end
end
