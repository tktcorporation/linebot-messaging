class Remind < ApplicationRecord
  belongs_to :bot
  has_many :remind_users, ->{ where(deleted: false) }, dependent: :destroy
  validates :name, presence: true
  validates :bot_id, presence: true
  validates :text, presence: true
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