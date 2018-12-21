class SessionLineuser < ApplicationRecord
  belongs_to :form
  belongs_to :lineuser

  validates :form_id, numericality: true
  validates :lineuser_id, numericality: true

  def self.get_with_form_and_lineuser(form, lineuser)
    self.find_by(form_id: lineuser.id, lineuser_id: lineuser.id)
  end

end