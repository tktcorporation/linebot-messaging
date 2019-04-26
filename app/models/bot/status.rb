class Bot::Status < ApplicationRecord
  belongs_to :bot
  has_many :lineuser_statuses
  has_many :lineuser, through: :lineuser_statuses
  validates :bot_id, numericality: true
  validates :name, presence: true, lt4bytes: true

  def destroy
    self.update_attributes(deleted: true)
  end

  def switch_active
    if self.is_cv_status
      self.is_cv_status = false
    else
      status_models = []
      self.bot.statuses.each do |status|
        status.is_cv_status = false
        status_models << status
      end
      Bot::Status.import status_models, on_duplicate_key_update: [:is_cv_status]
      self.is_cv_status = true
    end
    save
  end

  def self.get_cv_status
    self.find_by(is_cv_status: true)
  end

  def self.get(id)
    self.find(id)
  end

end