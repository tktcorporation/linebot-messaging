class Lineuser::InvitationCode < ApplicationRecord
  belongs_to :lineuser

  def self.get(id)
    self.find(id)
  end

end