class AddBusinessFieldsToAgencies < ActiveRecord::Migration[7.2]
  def change
    add_column :agencies, :tax_number,           :string   # الرقم الضريبي
    add_column :agencies, :commercial_registry,  :string   # السجل التجاري
    add_column :agencies, :commercial_license,   :string   # رقم الترخيص
    add_column :agencies, :professional_license, :string   # الترخيص المهني
    add_column :agencies, :company_registration, :string   # رقم الشركة

    add_column :agencies, :email,                :string
    add_column :agencies, :secondary_phone,      :string
    add_column :agencies, :website,              :string

    add_column :agencies, :bank_name,            :string   # اسم البنك
    add_column :agencies, :bank_account,         :string   # رقم الحساب
    add_column :agencies, :iban,                 :string
    add_column :agencies, :account_holder,       :string   # صاحب الحساب

    add_column :agencies, :authorized_person,    :string   # المفوّض بالتوقيع
    add_column :agencies, :founded_on,           :date     # تاريخ التأسيس
    add_column :agencies, :employees_count,      :integer  # عدد الموظفين
    add_column :agencies, :verified,             :boolean, default: false, null: false
    add_column :agencies, :verified_at,          :datetime
    add_column :agencies, :latitude,             :decimal, precision: 10, scale: 6
    add_column :agencies, :longitude,            :decimal, precision: 10, scale: 6

    add_index :agencies, :tax_number, unique: true, where: "tax_number IS NOT NULL"
    add_index :agencies, :commercial_registry, unique: true, where: "commercial_registry IS NOT NULL"
  end
end
