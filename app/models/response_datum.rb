class ResponseDatum < ApplicationRecord
  belongs_to :lineuser
  belongs_to :quick_reply

  validates :lineuser_id, numericality: true
  validates :quick_reply_id, numericality: true
  validates :response_text, presence: true, length: { in: 1..250 }

  def self.get_plural_with_lineuser_id(lineuser_id)
    self.where(lineuser_id: lineuser_id).includes(:lineuser, :quick_reply)
  end

  def self.save_data(lineuser, quick_reply_id, text)
    response_data = lineuser.response_data.find_or_initialize_by(quick_reply_id: quick_reply_id)
    response_data.update_attributes!(response_text: text)
  end

end