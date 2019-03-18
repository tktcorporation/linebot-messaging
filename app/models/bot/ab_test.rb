class Bot::AbTest < ApplicationRecord
  belongs_to :bot
  has_many :ab_test_forms, dependent: :destroy
  has_many :forms, through: :ab_test_forms
  accepts_nested_attributes_for :ab_test_forms

  def switch_active
    if self.is_active
      self.is_active = false
    else
      if old_active = self.bot.ab_tests.find_by(is_active: true)
        old_active.is_active = false
        old_active.save!
      end
      self.is_active = true
    end
    save!
  end

  def self.associate_forms(ab_test, ids_array)
    if ids_array.size < 2 || ids_array.size > 3
      raise "ids_array.size < 2 || ids_array.size > 3"
    end
    ids_array.each do |id|
      ab_test.ab_test_forms.create!(form_id: ab_test.bot.forms.get(id.to_i).id)
    end
  end

  def self.get(id)
    self.find(id)
  end

end