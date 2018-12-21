class ConvertedLineuser < ApplicationRecord
  belongs_to :lineuser
  belongs_to :form

  validates :form_id, numericality: true
  validates :lineuser_id, numericality: true

  def self.get_with_lineuser(lineuser)
    lineuser.converted_lineuser
  end

  def self.get(id)
    self.find(id)
  end

end
