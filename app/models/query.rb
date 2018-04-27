class Query < ApplicationRecord
  belongs_to :user, optional: true

  has_many :result
  has_many :seller_detail
end
