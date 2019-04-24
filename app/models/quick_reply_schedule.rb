class QuickReplySchedule < ApplicationRecord
  belongs_to :quick_reply

  validates :quick_reply_id, :duration_days, :summary, :available_day, :duration_num, :start_num, :term_num, presence: true
  validates :duration_days, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :duration_num, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 48 }
  validates :start_num, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }
  validates :term_num, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 12 }
  validate :available_day_cannot_in_all_of_off
  validate :consistency_check



  def self.create_option(quick_reply, quick_reply_schedule_params)
    quick_reply_schedule = QuickReplySchedule.find_or_initialize_by(quick_reply_id: quick_reply.id)
    available_day_str = ""
    quick_reply_schedule_params[:available_day].to_h.to_a.each{|day| available_day_str += day[1]}
    quick_reply_schedule.update_attributes!(duration_days: quick_reply_schedule_params[:duration_days], summary: quick_reply_schedule_params[:summary], available_day: available_day_str, duration_num: quick_reply_schedule_params[:duration_num], start_num: quick_reply_schedule_params[:start_num], term_num: quick_reply_schedule_params[:term_num], permission_count: quick_reply_schedule_params[:permission_count])
  end
  private
    def available_day_cannot_in_all_of_off
      if available_day.present? && available_day == "0000000"
        errors.add(:available_day, "は最低でも1つ有効にする必要があります")
      end
    end
    def consistency_check
      if duration_num.present? && start_num.present? && term_num.present?
        time = Time.local(2018, 12, 19, 0, 0, 0, 0)
        tommorow = time + 60 * 60 * 24
        start_time = time + 60 * 30 * start_num
        end_time = start_time + 60 * 60 * term_num
        if end_time > tommorow
          errors.add(:term_num, "は翌日にならないように設定してください")
        end
      end
    end

end