class Favourite < ApplicationRecord
  belongs_to :user
  has_one :result
end
