class Bot < ApplicationRecord
  has_many :logs, ->{ where(deleted: false) }
  has_many :reminds, ->{ where(deleted: false) }
  has_many :lineusers, ->{ where(deleted: false) }
  has_many :forms, ->{ where(deleted: false) }
  has_many :quick_replies, through: :forms
  has_many :statuses, ->{ where(deleted: false) }, class_name: "Bot::Status"
  has_many :reply_actions
  has_many :ab_tests
  has_many :check_notifications
  has_many :stock_images
  # has_many_attached :images
  has_one :notify_token, ->{ where(deleted: false) }
  has_one :google_api_set
  has_one :slack_api_set
  belongs_to :user

  scope :undeleted, ->{ where(deleted: false) }

  validates :name, presence: true, lt4bytes: true
  validates :channel_token, presence: true, lt4bytes: true
  validates :channel_secret, presence: true, lt4bytes: true
  validates :user_id, numericality: true
  validates :callback_hash, presence: true, lt4bytes: true

  def destroy
    self.deleted = true
    save
  end

  def get_status_array
    self.statuses.pluck(:name, :id)
  end

  def self.get_plural_with_user_id(current_user_id)
    self.undeleted.where(user_id: current_user_id)
  end

  def self.get(bot_id)
    self.undeleted.find(bot_id)
  end

  def self.get_with_form_id(form_id)
    self.undeleted.find_by(form_id: form_id)
  end

  def self.get_with_channel_secret(channel_secret)
    self.undeleted.find_by(channel_secret: channel_secret)
  end

  def self.get_with_callback_hash(callback_hash)
    self.find_by(callback_hash: callback_hash)
  end

  def self.get_with_callback_hash_of_google_auth(callback_hash)
    self.find_by(callback_hash_of_google_auth: callback_hash)
  end
end