class Group < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9-]+\z/, message: "only lowercase letters, numbers, and hyphens" }

  before_validation :generate_slug, on: :create, if: -> { slug.blank? }

  private

  def generate_slug
    self.slug = name.parameterize
  end
end
