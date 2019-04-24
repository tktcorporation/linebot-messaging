class Log < ApplicationRecord
  belongs_to :bot
  validates :bot_id, numericality: true
  validates :text, presence: true

  def self.get_plural_with_bot_id(bot_id)
    self.where(bot_id: bot_id)
  end

  def self.push_bulk(bot_id, logs)
    log_models = []
    logs.each {|log|
      log_models << self.new(
        bot_id: bot_id,
        text: log
      )
    }
    self.import log_models
  end
end
