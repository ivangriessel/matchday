class FixturesController < ApplicationController
  before_action :authenticate_user!

  def index
    @matchweek = Fixture.where(status: [ :scheduled, :live ])
                        .order(:kickoff_at)
                        .pick(:matchweek)
    @fixtures = @matchweek ? Fixture.for_matchweek(@matchweek).includes(:home_team, :away_team) : []
    @predictions = current_user.predictions.where(fixture: @fixtures).index_by(&:fixture_id)
    @matchweek_points = @predictions.values.sum { |p| p.points || 0 }
  end
end
