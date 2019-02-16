class Bot::Status < ApplicationRecord
  belongs_to :bot
  has_many :lineuser_statuses
  validates :bot_id, numericality: true
  validates :name, presence: true, lt4bytes: true

  def destroy
    self.update_attributes(deleted: true)
  end

  def self.get(id)
    self.find(id)
  end

end