class Report < ApplicationRecord
  scope :search, lambda { |query| where(['description LIKE ?', "%#{query}%"]) }
  scope :newest_first, lambda { order('created_at DESC') }
  scope :oldest_first, lambda { order('created_at ASC') }
  scope :updated_recently, lambda { order('updated_at DESC') }
  scope :updated_oldest, lambda { order('updated_at ASC') }
  belongs_to :user
end
