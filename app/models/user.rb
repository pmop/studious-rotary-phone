class User < ApplicationRecord
  has_secure_password

  NAME_REGEX = %r{[A-z]{3,12}+( ?[A-z]+)*}.freeze

  #validates :password, presence: true,
  #                     confirmation: true

  validates :name, presence: true,
                   format: { with: NAME_REGEX },
                   length: { maximum: 40 }

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: true

  def generate_password_token!
    self.reset_password_token = SecureRandom.urlsafe_base64
    until not User.exists?(reset_password_token: self.reset_password_token)
      self.reset_password_token = SecureRandom.urlsafe_base64
    end 
    self.reset_password_token_expires_at = 1.hour.from_now
    save!
  end

  def clear_password_token!
    self.reset_password_token = nil
    self.reset_password_token_expires_at = nil
    save!
  end

  def as_json
    JSON.generate({
      name:       self.name,
      email:      self.email,
      created_at: self.created_at,
      updated_at: self.updated_at
    })
  end

  def to_json
    as_json
  end
end
