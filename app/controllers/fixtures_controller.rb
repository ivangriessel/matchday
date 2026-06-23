class FixturesController < ApplicationController
  before_action :authenticate_user!

  def index
    @matchweek = Fixture.where(status: [ :scheduled, :live ])
                        .order(:kickoff_at)
                        .pick(:matchweek)
    @fixtures = @matchweek ? Fixture.for_matchweek(@matchweek).includes(:home_team, :away_team) : []
  end
end
