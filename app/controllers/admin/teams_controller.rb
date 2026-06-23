class Admin::TeamsController < Admin::BaseController
  before_action :set_team, only: [ :edit, :update, :destroy ]

  def index
    @teams = Team.order(:name)
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    if @team.save
      redirect_to admin_teams_path, notice: "Team created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @team.update(team_params)
      redirect_to admin_teams_path, notice: "Team updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @team.destroy
    redirect_to admin_teams_path, notice: "Team deleted."
  end

  private

  def set_team
    @team = Team.find(params[:id])
  end

  def team_params
    params.require(:team).permit(:name, :short_code, :crest_url)
  end
end
