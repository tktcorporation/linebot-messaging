class Remind < ApplicationRecord
  belongs_to :bot
  has_many :remind_users, ->{ where(deleted: false) }, dependent: :destroy

  validates :name, presence: true, lt4bytes: true, length: { in: 1..100 }
  validates :bot_id, numericality: true
  validates :text, presence: true, lt4bytes: true, length: { in: 1..250 }
  validates :ignition_time, presence: true
  validates :completed, presence: true, inclusion: { in: [true, false] }
  validates :enable, presence: true, inclusion: { in: [true, false] }


  scope :undeleted, ->{ where(deleted: false) }
  scope :uncompleted, ->{ where(completed: false)}
  scope :enable, ->{ where(enable: true) }

  def destroy
    self.deleted = true
    save
  end

  def self.get(remind_id)
    self.undeleted.find(remind_id)
  end

  def self.get_plural_with_bot_id(bot_id)
    self.undeleted.where(bot_id: bot_id)
  end

  def self.delete_remind(remind_id)
    remind = self.get(remind_id)
    if remind.destroy
      p "success deleted"
    end
  end

  def self.all_of_enable
    self.undeleted.uncompleted.enable
  end
end