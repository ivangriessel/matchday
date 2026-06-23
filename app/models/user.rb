class User < ApplicationRecord
  passwordless_with :email

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :predictions, dependent: :destroy

  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true

  normalizes :email, with: ->(email) { email.strip.downcase }
end
