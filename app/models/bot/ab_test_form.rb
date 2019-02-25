class Bot::AbTestForm < ApplicationRecord
  belongs_to :ab_test
  belongs_to :form
end