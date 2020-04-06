class Report < ApplicationRecord
  scope :search, lambda { |query| where(['description LIKE ?', "%#{query}%"]) }
  belongs_to :user
end
