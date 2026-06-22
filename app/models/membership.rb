class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  enum :role, { member: "member", admin: "admin" }

  validates :role, presence: true
  validates :user_id, uniqueness: { scope: :group_id, message: "is already a member of this group" }
end
