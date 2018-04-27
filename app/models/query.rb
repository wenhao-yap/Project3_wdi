class Query < ApplicationRecord
  belongs_to :user, optional: true
  has_many :result
end
