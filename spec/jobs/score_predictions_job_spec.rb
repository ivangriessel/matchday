require "rails_helper"

RSpec.describe ScorePredictionsJob, type: :job do
  it "scores all predictions for the given fixture" do
    fixture = create(:fixture, :finished, home_score: 2, away_score: 1)
    prediction = build(:prediction, fixture: fixture, home_score: 2, away_score: 1)
    prediction.save!(validate: false)

    ScorePredictionsJob.perform_now(fixture.id)

    expect(prediction.reload.points).to eq(5)
  end
end
