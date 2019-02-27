class Bot::CheckNotification < ApplicationRecord
  belongs_to :bot
  has_many :check_notification_quick_replies, dependent: :destroy
  has_many :quick_replies, through: :check_notification_quick_replies


  def self.associate_quick_replies(check_notification, ids_array, form)
    ids_array.each do |id|
      check_notification.check_notification_quick_replies.create!(quick_reply_id: form.quick_replies.get(id.to_i).id)
    end
  end

  def self.get(id)
    self.find(id)
  end
end