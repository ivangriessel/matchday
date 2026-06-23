class Admin::FixturesController < Admin::BaseController
  before_action :set_fixture, only: [ :edit, :update, :destroy ]

  def index
    @fixtures = Fixture.includes(:home_team, :away_team)
                       .order(:season, :matchweek, :kickoff_at)
  end

  def new
    @fixture = Fixture.new(season: current_season)
    @teams = Team.order(:name)
  end

  def create
    @fixture = Fixture.new(fixture_params)
    if @fixture.save
      redirect_to admin_fixtures_path, notice: "Fixture created."
    else
      @teams = Team.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @teams = Team.order(:name)
  end

  def update
    if @fixture.update(fixture_params)
      redirect_to admin_fixtures_path, notice: "Fixture updated."
    else
      @teams = Team.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @fixture.destroy
    redirect_to admin_fixtures_path, notice: "Fixture deleted."
  end

  private

  def set_fixture
    @fixture = Fixture.find(params[:id])
  end

  def fixture_params
    params.require(:fixture).permit(
      :season, :matchweek, :home_team_id, :away_team_id,
      :kickoff_at, :home_score, :away_score, :status
    )
  end

  def current_season
    "2025-26"
  end
end
