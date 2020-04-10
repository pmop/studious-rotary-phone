class Report < ApplicationRecord
  scope :search, lambda { |query| where(['description LIKE ?', "%#{query}%"]) }
  scope :newest_first, lambda { order('created_at DESC') }
  scope :oldest_first, lambda { order('created_at ASC') }
  scope :updated_recently, lambda { order('updated_at DESC') }
  scope :updated_oldest, lambda { order('updated_at ASC') }
  belongs_to :user

  def as_json
    JSON.generate({
        status:      self.status,
        description: self.description,
        user_name:   self.user.name ,
        user_email:  self.user.email,
        lat:         self.lat,
        lng:         self.lng,
        response:    self.response,
        created_at:  self.created_at,
        updated_at:  self.updated_at
    })
  end

  def to_json
    as_json
  end
end
