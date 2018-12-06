class QuickReplySchedule < ApplicationRecord
  belongs_to :quick_reply, optional: true

  validates :quick_reply_id, presence: true
  validates :duration_days, presence: true
end