FactoryBot.define do
  factory :chat_message do
    user { nil }
    session_id { "MyString" }
    role { 1 }
    content { "MyText" }
    metadata { "" }
  end
end
