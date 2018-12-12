class NotifyToken < ApplicationRecord
  belongs_to :bot
  validates :bot_id, presence: true

  def self.get_with_bot_id(bot_id)
    self.find_by(bot_id: bot_id)
  end

  def self.update_or_create(bot_id, token)
    notify_token = self.find_or_initialize_by(bot_id: bot_id)
    notify_token.update_attributes!(access_token: token)
  end
end