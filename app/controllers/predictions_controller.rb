class PredictionsController < ApplicationController
  before_action :authenticate_user!

  def create
    params.fetch(:predictions, {}).each do |fixture_id, scores|
      fixture = Fixture.find_by(id: fixture_id)
      next if fixture.nil? || fixture.locked?

      prediction = current_user.predictions.find_or_initialize_by(fixture: fixture)
      prediction.home_score = scores[:home_score].to_i
      prediction.away_score = scores[:away_score].to_i
      prediction.save
    end

    redirect_to root_path, notice: "Predictions saved."
  end
end
