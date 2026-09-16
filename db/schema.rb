# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_09_17_014206) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agencies", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.integer "kind"
    t.string "phone"
    t.string "whatsapp"
    t.string "address"
    t.bigint "city_id", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tax_number"
    t.string "commercial_registry"
    t.string "commercial_license"
    t.string "professional_license"
    t.string "company_registration"
    t.string "email"
    t.string "secondary_phone"
    t.string "website"
    t.string "bank_name"
    t.string "bank_account"
    t.string "iban"
    t.string "account_holder"
    t.string "authorized_person"
    t.date "founded_on"
    t.integer "employees_count"
    t.boolean "verified", default: false, null: false
    t.datetime "verified_at"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "facebook_url"
    t.string "instagram_url"
    t.string "tiktok_url"
    t.string "youtube_url"
    t.string "twitter_url"
    t.string "telegram_url"
    t.integer "approval_status", default: 0, null: false
    t.datetime "approved_at"
    t.integer "approved_by"
    t.text "rejection_reason"
    t.index ["approval_status"], name: "index_agencies_on_approval_status"
    t.index ["city_id"], name: "index_agencies_on_city_id"
    t.index ["commercial_registry"], name: "index_agencies_on_commercial_registry", unique: true, where: "(commercial_registry IS NOT NULL)"
    t.index ["tax_number"], name: "index_agencies_on_tax_number", unique: true, where: "(tax_number IS NOT NULL)"
    t.index ["user_id"], name: "index_agencies_on_user_id"
  end

  create_table "attendance_records", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "worker_id", null: false
    t.date "work_date"
    t.time "check_in"
    t.time "check_out"
    t.decimal "total_hours"
    t.decimal "overtime_hours"
    t.integer "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_attendance_records_on_user_id"
    t.index ["worker_id"], name: "index_attendance_records_on_worker_id"
  end

  create_table "buildings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "city_id", null: false
    t.string "name"
    t.string "address"
    t.integer "floors_count"
    t.integer "units_per_floor"
    t.integer "year_built"
    t.text "description"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_buildings_on_city_id"
    t.index ["user_id"], name: "index_buildings_on_user_id"
  end

  create_table "cars", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "city_id", null: false
    t.string "title"
    t.text "description"
    t.string "brand"
    t.string "car_model"
    t.integer "year"
    t.decimal "price"
    t.string "currency"
    t.integer "mileage"
    t.integer "fuel_type"
    t.integer "transmission"
    t.integer "condition"
    t.integer "body_type"
    t.string "color"
    t.integer "doors"
    t.integer "seats"
    t.integer "engine_size"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_ac"
    t.boolean "has_airbags"
    t.boolean "has_abs"
    t.boolean "has_sunroof"
    t.boolean "has_navigation"
    t.boolean "has_bluetooth"
    t.boolean "has_camera"
    t.boolean "has_leather_seats"
    t.boolean "has_alloy_wheels"
    t.boolean "has_cruise_control"
    t.boolean "has_parking_sensors"
    t.boolean "has_power_windows"
    t.boolean "has_central_lock"
    t.boolean "has_heated_seats"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "youtube_url"
    t.index ["city_id"], name: "index_cars_on_city_id"
    t.index ["user_id"], name: "index_cars_on_user_id"
  end

  create_table "cities", force: :cascade do |t|
    t.string "name_ar"
    t.string "name_en"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contracts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id"
    t.bigint "tenant_id"
    t.date "start_date"
    t.date "end_date"
    t.decimal "amount"
    t.string "currency"
    t.integer "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "car_id"
    t.bigint "customer_id"
    t.integer "kind", default: 0, null: false
    t.decimal "daily_rate", precision: 12, scale: 2
    t.integer "days"
    t.integer "start_odometer"
    t.integer "end_odometer"
    t.index ["car_id"], name: "index_contracts_on_car_id"
    t.index ["customer_id"], name: "index_contracts_on_customer_id"
    t.index ["property_id"], name: "index_contracts_on_property_id"
    t.index ["tenant_id"], name: "index_contracts_on_tenant_id"
    t.index ["user_id"], name: "index_contracts_on_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name"
    t.string "phone"
    t.string "national_id"
    t.string "address"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["phone"], name: "index_customers_on_phone"
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "maintenances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "maintainable_type", null: false
    t.bigint "maintainable_id", null: false
    t.string "title"
    t.text "description"
    t.decimal "cost", precision: 15, scale: 2
    t.string "currency", default: "SYP"
    t.date "performed_on"
    t.date "next_due_on"
    t.integer "kind", default: 9
    t.integer "status", default: 0
    t.text "parts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["maintainable_type", "maintainable_id"], name: "index_maintenances_on_maintainable"
    t.index ["next_due_on"], name: "index_maintenances_on_next_due_on"
    t.index ["status"], name: "index_maintenances_on_status"
    t.index ["user_id"], name: "index_maintenances_on_user_id"
  end

  create_table "payment_requests", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "subscription_id", null: false
    t.bigint "plan_id", null: false
    t.decimal "amount"
    t.string "currency"
    t.integer "payment_method"
    t.string "reference_number"
    t.date "transfer_date"
    t.string "sender_name"
    t.string "sender_phone"
    t.integer "status"
    t.text "admin_notes"
    t.datetime "processed_at"
    t.integer "processed_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_payment_requests_on_plan_id"
    t.index ["subscription_id"], name: "index_payment_requests_on_subscription_id"
    t.index ["user_id"], name: "index_payment_requests_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "contract_id", null: false
    t.bigint "tenant_id"
    t.decimal "amount"
    t.string "currency"
    t.date "due_on"
    t.date "paid_on"
    t.integer "payment_method"
    t.integer "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "customer_id"
    t.index ["contract_id"], name: "index_payments_on_contract_id"
    t.index ["customer_id"], name: "index_payments_on_customer_id"
    t.index ["tenant_id"], name: "index_payments_on_tenant_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.string "name_ar"
    t.string "slug"
    t.decimal "price_syp"
    t.decimal "price_usd"
    t.integer "max_listings"
    t.integer "duration_days"
    t.text "features"
    t.boolean "active"
    t.integer "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "platform_settings", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "city_id", null: false
    t.string "title"
    t.text "description"
    t.integer "property_type"
    t.integer "listing_type"
    t.decimal "price"
    t.string "currency"
    t.integer "size"
    t.integer "floor"
    t.integer "total_floors"
    t.integer "rooms"
    t.integer "bathrooms"
    t.string "address"
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_elevator"
    t.boolean "has_parking"
    t.boolean "has_garden"
    t.boolean "has_pool"
    t.boolean "has_balcony"
    t.boolean "furnished"
    t.boolean "has_water_well"
    t.boolean "has_solar_energy"
    t.boolean "has_generator"
    t.boolean "has_internet"
    t.boolean "has_security"
    t.boolean "has_central_heating"
    t.boolean "has_ac"
    t.decimal "latitude"
    t.decimal "longitude"
    t.bigint "building_id"
    t.string "unit_number"
    t.string "unit_label"
    t.string "youtube_url"
    t.index ["building_id"], name: "index_properties_on_building_id"
    t.index ["city_id"], name: "index_properties_on_city_id"
    t.index ["user_id"], name: "index_properties_on_user_id"
  end

  create_table "salary_advances", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "worker_id", null: false
    t.decimal "amount"
    t.string "currency"
    t.date "advance_date"
    t.text "reason"
    t.boolean "settled"
    t.date "settled_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_salary_advances_on_user_id"
    t.index ["worker_id"], name: "index_salary_advances_on_worker_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "plan_id", null: false
    t.integer "status"
    t.date "starts_on"
    t.date "ends_on"
    t.integer "listings_used"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "property_id", null: false
    t.string "full_name"
    t.string "phone"
    t.string "national_id"
    t.date "start_date"
    t.date "end_date"
    t.decimal "rent_amount"
    t.string "currency"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id"], name: "index_tenants_on_property_id"
    t.index ["user_id"], name: "index_tenants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role", default: 0, null: false
    t.string "full_name"
    t.string "phone"
    t.boolean "admin", default: false, null: false
    t.index ["admin"], name: "index_users_on_admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "worker_holidays", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "worker_id", null: false
    t.date "holiday_date"
    t.integer "holiday_type"
    t.boolean "paid"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_worker_holidays_on_user_id"
    t.index ["worker_id"], name: "index_worker_holidays_on_worker_id"
  end

  create_table "worker_payments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "worker_id", null: false
    t.decimal "amount"
    t.string "currency"
    t.date "paid_on"
    t.date "for_month"
    t.integer "payment_method"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_worker_payments_on_user_id"
    t.index ["worker_id"], name: "index_worker_payments_on_worker_id"
  end

  create_table "workers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "full_name"
    t.string "phone"
    t.string "position"
    t.decimal "salary"
    t.string "currency"
    t.date "hired_on"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "pay_type", default: 0, null: false
    t.decimal "hourly_rate", precision: 12, scale: 2
    t.decimal "daily_rate", precision: 12, scale: 2
    t.decimal "overtime_multiplier", precision: 3, scale: 2, default: "1.5"
    t.integer "working_hours_per_day", default: 8
    t.integer "working_days_per_month", default: 26
    t.string "national_id"
    t.string "address"
    t.date "birth_date"
    t.string "emergency_contact"
    t.string "emergency_phone"
    t.decimal "monthly_target", precision: 12, scale: 2
    t.decimal "monthly_salary", precision: 12, scale: 2, default: "0.0"
    t.index ["user_id"], name: "index_workers_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agencies", "cities"
  add_foreign_key "agencies", "users"
  add_foreign_key "attendance_records", "users"
  add_foreign_key "attendance_records", "workers"
  add_foreign_key "buildings", "cities"
  add_foreign_key "buildings", "users"
  add_foreign_key "cars", "cities"
  add_foreign_key "cars", "users"
  add_foreign_key "contracts", "cars"
  add_foreign_key "contracts", "customers"
  add_foreign_key "contracts", "properties"
  add_foreign_key "contracts", "tenants"
  add_foreign_key "contracts", "users"
  add_foreign_key "customers", "users"
  add_foreign_key "maintenances", "users"
  add_foreign_key "payment_requests", "plans"
  add_foreign_key "payment_requests", "subscriptions"
  add_foreign_key "payment_requests", "users"
  add_foreign_key "payments", "contracts"
  add_foreign_key "payments", "customers"
  add_foreign_key "payments", "tenants"
  add_foreign_key "payments", "users"
  add_foreign_key "properties", "buildings"
  add_foreign_key "properties", "cities"
  add_foreign_key "properties", "users"
  add_foreign_key "salary_advances", "users"
  add_foreign_key "salary_advances", "workers"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "users"
  add_foreign_key "tenants", "properties"
  add_foreign_key "tenants", "users"
  add_foreign_key "worker_holidays", "users"
  add_foreign_key "worker_holidays", "workers"
  add_foreign_key "worker_payments", "users"
  add_foreign_key "worker_payments", "workers"
  add_foreign_key "workers", "users"
end
