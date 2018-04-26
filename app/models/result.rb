class Result < ApplicationRecord
  belongs_to :query
  has_one :favourite
end
