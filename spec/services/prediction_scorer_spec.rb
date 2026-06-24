require "rails_helper"

RSpec.describe PredictionScorer do
  let(:fixture) { create(:fixture, :finished, home_score: 2, away_score: 1) }

  def score_for(home, away)
    prediction = build(:prediction, fixture: fixture, home_score: home, away_score: away)
    prediction.save!(validate: false)
    PredictionScorer.score(prediction)
    prediction.reload.points
  end

  describe ".score" do
    it "awards 5 points for an exact score" do
      expect(score_for(2, 1)).to eq(5)
    end

    it "awards 2 points for the correct outcome only" do
      expect(score_for(3, 0)).to eq(2)
    end

    it "awards 0 points for a wrong outcome" do
      expect(score_for(1, 1)).to eq(0)
      expect(score_for(0, 2)).to eq(0)
    end

    it "awards 2 points for predicting a draw when the result is a draw" do
      fixture.update!(home_score: 1, away_score: 1)
      expect(score_for(2, 2)).to eq(2)
    end

    it "awards 5 points for predicting the exact draw score" do
      fixture.update!(home_score: 1, away_score: 1)
      expect(score_for(1, 1)).to eq(5)
    end

    it "nils out points when the result is removed" do
      prediction = build(:prediction, fixture: fixture, home_score: 2, away_score: 1, points: 5)
      prediction.save!(validate: false)
      fixture.update_columns(home_score: nil, away_score: nil)
      PredictionScorer.score(prediction)
      expect(prediction.reload.points).to be_nil
    end
  end
end
