class ConvertedLineuser < ApplicationRecord
  belongs_to :lineuser
  belongs_to :form

  def self.get_with_lineuser(lineuser)
    lineuser.converted_lineuser
  end

  def self.get(id)
    self.find(id)
  end

end
