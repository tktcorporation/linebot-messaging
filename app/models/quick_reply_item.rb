class QuickReplyItem < ApplicationRecord
  belongs_to :quick_reply
  scope :undeleted, ->{ where(deleted: false) }

  validates :quick_reply_id, presence: true
  validates :text, presence: true

  def destroy
    quick_reply = self.quick_reply
    self.deleted = true
    save
    if !quick_reply.quick_reply_items
      quick_reply.is_normal_message = true
      quick_reply.save
    end
  end

  def self.get(id)
    self.undeleted.find(id)
  end
end