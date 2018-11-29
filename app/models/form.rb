class Form < ApplicationRecord
  has_many :quick_replies, ->{ where(deleted: false) }
  has_many :converted_lineusers
  has_many :session_lineusers
  belongs_to :bot

  scope :undeleted, ->{ where(deleted: false) }

  validates :name, presence: true
  validates :bot_id, presence: true
  validates :describe_text, presence: true

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