class MakeUserIdNullableOnChatMessages < ActiveRecord::Migration[7.2]
  def change
    change_column_null :chat_messages, :user_id, true
  end
end
