class QuickReplySchedule < ApplicationRecord
  belongs_to :quick_reply

  validates :quick_reply_id, presence: true
  validates :duration_days, presence: true

  def self.create_option(quick_reply, duration_days, summary)
    quick_reply_schedule = QuickReplySchedule.find_or_initialize_by(quick_reply_id: quick_reply.id)
    quick_reply_schedule.update_attributes!(duration_days: duration_days, summary: summary)
  end
end