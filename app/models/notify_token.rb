class NotifyToken < ApplicationRecord
  belongs_to :bot
  validates :bot_id, presence: true

  def self.get_with_bot_id(bot_id)
    self.find_by(bot_id: bot_id)
  end

  def self.update_or_create(token, bot_id)
    if notify_token = self.get_with_bot_id(bot_id)
      notify_token.update(access_token: token)
    else
      self.create(access_token: token, bot_id: bot_id)
    end
  end
end