class GoogleApiSet < ApplicationRecord
  belongs_to :bot

  validates :client_secret, lt4bytes: true
  validates :client_id, lt4bytes: true
  validates :bot_id, numericality: true

  def self.update_or_create(bot_id, client_id, client_secret)
    google_api_set = self.find_or_initialize_by(bot_id: bot_id)
    google_api_set.update_attributes!(client_id: client_id, client_secret: client_secret)
  end

end