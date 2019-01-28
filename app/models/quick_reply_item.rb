class QuickReplyItem < ApplicationRecord
  belongs_to :quick_reply
  scope :undeleted, ->{ where(deleted: false) }

  validates :quick_reply_id, numericality: true
  validates :text, presence: true, length: { in: 1..230 }
  validates :next_reply_id, numericality: true, allow_blank: true

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

  def self.update_nexts(items_flow_params)
    #ループの数だけロードが走ってしまう
    items_flow_params.to_h.map do |id, item_param|
      item = self.get(id)
      item.update_attributes(item_param)
    end
  end
end