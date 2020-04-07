class User < ApplicationRecord
  has_secure_password

  NAME_REGEX = %r{[A-z]{3,12}+( ?[A-z]+)*}.freeze

  validates :password_digest, presence: true

  validates :name, presence: true,
                   format: { with: NAME_REGEX },
                   length: { maximum: 40 }

  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: true
end
