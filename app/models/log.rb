class Log < ApplicationRecord
  belongs_to :bot
  validates :bot_id, numericality: true
  validates :text, presence: true

  def self.get_plural_with_bot_id(bot_id)
    self.where(bot_id: bot_id)
  end
end