class Message < ApplicationRecord
  belongs_to :lineuser

  validates :content, presence: true
  validates :lineuser_id, numericality: true
  validates :to_bot, inclusion: { in: [true, false] }
  validates :msg_type, numericality: true

  scope :undeleted, ->{ where(deleted: false) }
  scope :order_asc, ->{ order(created_at: :asc) }
  def self.get_plural_with_lineuser_id(lineuser_id)
    Message.where(lineuser_id: lineuser_id).order_asc
  end
  def self.get(id)
    self.find(id)
  end
end