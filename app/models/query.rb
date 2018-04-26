class Query < ApplicationRecord
  belongs_to :user
  has_many :result
end
