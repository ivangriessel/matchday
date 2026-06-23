class Prediction < ApplicationRecord
  belongs_to :user
  belongs_to :fixture

  validates :home_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :away_score, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: { scope: :fixture_id }
  validate :fixture_not_locked, on: [ :create, :update ]

  before_save :set_submitted_at

  def locked?
    fixture.present? && fixture.locked?
  end

  private

  def fixture_not_locked
    errors.add(:base, "Predictions cannot be changed after kickoff") if locked?
  end

  def set_submitted_at
    self.submitted_at = Time.current
  end
end
