class User < ApplicationRecord
  has_many :orders
  has_many :reviews

  # presence: true — must be present
  # length — length validation, here limiting name to 50 characters
  # uniqueness — ensures email is unique across users
  # format — validates the format of the email using a regular expression
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
