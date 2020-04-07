class Report < ApplicationRecord
  scope :search, lambda { |query| where(['description LIKE ?', "%#{query}%"]) }
  scope :newest_first, lambda { |query| order('created_at DESC') }
  scope :oldest_first, lambda { |query| order('created_at ASC') }
  scope :updated_recently, lambda { |query| order('updated_at DESC') }
  scope :updated_oldest, lambda { |query| order('updated_at ASC') }
  belongs_to :user
end
