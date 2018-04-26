class Query < ApplicationRecord
	has_many :favourite
	belongs_to :user
end
