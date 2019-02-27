class Bot::CheckNotificationQuickReply < ApplicationRecord
  belongs_to :check_notification
  belongs_to :quick_reply
end