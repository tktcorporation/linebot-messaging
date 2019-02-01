class Bot::LineuserStatus < ApplicationRecord
  belongs_to :lineuser
  belongs_to :status, optional: true
  validates :lineuser_id, numericality: true
  validates :status_id, numericality: true, allow_blank: true

  def self.create_or_update(lineuser_status_params, lineuser)
    if lineuser.lineuser_status.present?
      lineuser.lineuser_status.update_attributes!(lineuser_status_params)
    else
      status = lineuser.build_lineuser_status(lineuser_status_params)
      status.save!
    end
  end
end