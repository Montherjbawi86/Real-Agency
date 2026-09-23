class ChatMessage < ApplicationRecord
  belongs_to :user, optional: true

  enum :role, { user: 0, assistant: 1 }, default: :user

  validates :session_id, presence: true
  validates :content, presence: true

  scope :for_session, ->(sid) { where(session_id: sid).order(:created_at) }
end
