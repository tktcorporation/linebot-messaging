class Bot::StockImage < ApplicationRecord
  belongs_to :bot
  validates :bot_id, numericality: true
  mount_uploader :image, ImageUploader
end