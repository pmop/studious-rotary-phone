class User < ApplicationRecord
  NAME_REGEX = /^[A-z]{3,12}+( ?[A-z]+)*$/.freeze

  validates :password_digest, presence: true

  validates :name, presence: true,
                   with: NAME_REGEX,
                   length: { maximum: 40 }

  validates :email, presence: true,
                    with: URI::MailTo::EMAIL_REGEXP,
                    uniqueness: true
end
