class AddApprovalToAgencies < ActiveRecord::Migration[7.2]
  def change
    add_column :agencies, :approval_status, :integer, default: 0, null: false
    add_column :agencies, :approved_at,     :datetime
    add_column :agencies, :approved_by,     :integer
    add_column :agencies, :rejection_reason, :text
    add_index  :agencies, :approval_status
  end
end
