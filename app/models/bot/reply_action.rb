class Bot::ReplyAction < ApplicationRecord
  belongs_to :bot
  belongs_to :quick_reply

  scope :is_active, ->{ where(is_active: true) }

  validates :name, presence: true, lt4bytes: true, length: { in: 1..250 }
  validates :quick_reply_id, numericality: true
  validates :text, presence: true, lt4bytes: true
  validates :is_active, presence: true

  def self.get(id)
    self.find(id)
  end

end