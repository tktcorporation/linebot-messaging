class Bot::SlackApiSet < ApplicationRecord
  belongs_to :bot
  validates :webhook_url, lt4bytes: true
  validates :bot_id, numericality: true

  def self.update_or_create(bot, webhook_url)
    slack_api_set = self.find_or_initialize_by(bot_id: bot.id)
    slack_api_set.update_attributes!(webhook_url: webhook_url)
  end

end