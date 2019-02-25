class Bot::AbTest < ApplicationRecord
  belongs_to :bot
  has_many :ab_test_forms
  accepts_nested_attributes_for :ab_test_forms

  def self.associate_forms(ab_test, ids_array)
    ids_array.each do |id|
      ab_test.ab_test_forms.create!(form_id: ab_test.bot.forms.get(id.to_i).id)
    end
  end
end