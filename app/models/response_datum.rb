class ResponseDatum < ApplicationRecord
  belongs_to :lineuser
  belongs_to :quick_reply

  validates :lineuser_id, presence: true
  validates :quick_reply_id, presence: true
  validates :response_text, presence: true

  def self.get_plural_with_lineuser_id(lineuser_id)
    self.where(lineuser_id: lineuser_id).includes(:lineuser, :quick_reply)
  end

end