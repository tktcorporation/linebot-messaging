class Form < ApplicationRecord
  has_many :quick_replies, ->{ where(deleted: false) }
  has_many :converted_lineusers
  has_many :session_lineusers
  has_many :ab_test_forms
  has_many :ab_tests, through: :ab_test_forms
  belongs_to :bot

  scope :undeleted, ->{ where(deleted: false) }

  validates :name, presence: true, lt4bytes: true
  validates :bot_id, numericality: true
  validates :describe_text, presence: true, lt4bytes: true
  validates :deleted, inclusion: { in: [true, false] }
  validates :is_active, inclusion: { in: [true, false] }
  validates :first_reply_id, numericality: true, allow_blank: true

  def destroy
    self.deleted = true
    save
  end

  def switch_active_do(form)
    if self.is_active
      self.is_active = false
    else
      if old_active = form.bot.forms.find_by(is_active: true)
        old_active.is_active = false
        old_active.save
      end
      self.is_active = true
    end
    save
  end

  def self.get(id)
    self.undeleted.find(id)
  end

  def self.get_active_with_lineuser(lineuser)
    lineuser.bot.forms.find_by(is_active: true)
  end
end