class QuickReplyText < ApplicationRecord
  belongs_to :quick_reply
  has_many :quick_reply_text_flags

  validates :quick_reply_id, presence: true

  def self.create_option(quick_reply)
    quick_reply_text = QuickReplyText.find_or_initialize_by(quick_reply_id: quick_reply.id)
    quick_reply_text.save
  end
end