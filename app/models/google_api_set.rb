class GoogleApiSet < ApplicationRecord
  belongs_to :bot

  validates :client_secret, presence: true
  validates :client_id, presence: true
  validates :bot_id, presence: true

  def self.update_or_create(bot_id, client_id, client_secret)
    google_api_set = self.find_or_initialize_by(bot_id: bot_id)
    google_api_set.update_attributes!(client_id: client_id, client_secret: client_secret)
  end

end