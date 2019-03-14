class Lineuser::InvitationCode < ApplicationRecord
  belongs_to :lineuser

  validates :code, presence: true
  validates :lineuser_id, presence: true

  def self.get(id)
    self.find(id)
  end

end