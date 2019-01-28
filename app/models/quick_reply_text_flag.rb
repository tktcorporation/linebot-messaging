class QuickReplyTextFlag < ApplicationRecord
  belongs_to :quick_reply_text
  belongs_to :lineuser

  validates :quick_reply_text_id, numericality: true
  validates :lineuser_id, numericality: true
  validates :is_accepting, inclusion: { in: [true, false] }


  def self.initialize_accepting(quick_reply, lineuser)
    quick_reply_text = quick_reply.quick_reply_text
    flag = quick_reply_text.quick_reply_text_flags.find_or_initialize_by(quick_reply_text_id: quick_reply_text.id)
    flag.update_attributes!(is_accepting: true, lineuser_id: lineuser.id)
  end

  def self.accepted(lineuser)
    lineuser.quick_reply_text_flags.find_by(is_accepting: true).update_attributes!(is_accepting: false)
  end
end