class Fixture < ApplicationRecord
  belongs_to :home_team, class_name: "Team", inverse_of: :home_fixtures
  belongs_to :away_team, class_name: "Team", inverse_of: :away_fixtures
  has_many :predictions, dependent: :destroy

  enum :status, { scheduled: "scheduled", live: "live", finished: "finished", postponed: "postponed" }

  validates :season, presence: true
  validates :matchweek, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :kickoff_at, presence: true
  validates :status, presence: true
  validate :teams_must_differ

  scope :for_matchweek, ->(mw) { where(matchweek: mw).order(:kickoff_at) }
  scope :upcoming, -> { scheduled.order(:kickoff_at) }

  def locked?
    kickoff_at <= Time.current
  end

  private

  def teams_must_differ
    errors.add(:away_team, "must differ from home team") if home_team_id == away_team_id
  end
end
