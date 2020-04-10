class Report < ApplicationRecord
  scope :search, lambda { |query| where(['description LIKE ?', "%#{query}%"]) }
  scope :sort_by_creation, lambda { |ord| order(created_at: ord) }
  scope :sort_by_update, lambda { |ord| order(updated_at: ord) }
  belongs_to :user

  before_save :change_status

  def as_json
    JSON.generate as_filtered_hash
  end

  def as_filtered_hash
    {
        status:      self.status,
        description: self.description,
        user_name:   self.user.name ,
        user_email:  self.user.email,
        lat:         self.lat,
        lng:         self.lng,
        response:    self.response,
        created_at:  self.created_at,
        updated_at:  self.updated_at
    }
  end

  def to_json
    as_json
  end

  private

  def change_status
    self.status = 'new' if self.status.nil? && self.response.nil?
    self.status = 'replied' if !self.status.nil? && !self.response.nil?
    self.status = 'edited' if !self.status.nil? && self.response.nil?
  end
end
