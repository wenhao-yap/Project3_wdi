class Query < ApplicationRecord
	has_many :favourite
	belong_to :user
end
