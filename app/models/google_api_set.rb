class GoogleApiSet < ApplicationRecord
  belongs_to :bot

  validates :access_token, presence: true
  validates :bot_id, presence: true

end