class Team < ApplicationRecord
  has_many :home_fixtures, class_name: "Fixture", foreign_key: :home_team_id,
           dependent: :destroy, inverse_of: :home_team
  has_many :away_fixtures, class_name: "Fixture", foreign_key: :away_team_id,
           dependent: :destroy, inverse_of: :away_team

  validates :name, presence: true, uniqueness: true
  validates :short_code, presence: true, uniqueness: true
end
