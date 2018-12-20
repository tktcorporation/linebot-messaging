class Message < ApplicationRecord
  belongs_to :lineuser

  validates :content, presence: true
  validates :lineuser_id, presence: true, numericality: true
  validates :to_bot, presence: true, inclusion: { in: [true, false] }

  scope :undeleted, ->{ where(deleted: false) }
  scope :order_asc, ->{ order(created_at: :asc) }
  def self.get_plural_with_lineuser_id(lineuser_id)
    Message.where(lineuser_id: lineuser_id).order_asc
  end
  def self.get(id)
    self.find(id)
  end
end