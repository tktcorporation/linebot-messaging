class RemindUser < ApplicationRecord
  validates :remind_id, presence: true
  validates :lineuser_id, presence: true
  belongs_to :remind
  belongs_to :lineuser

  def self.get_plural_with_remind_id(remind_id)
    self.where(remind_id: remind_id)
  end
end
