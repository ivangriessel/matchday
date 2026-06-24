class ScorePredictionsJob < ApplicationJob
  queue_as :default

  def perform(fixture_id)
    fixture = Fixture.find(fixture_id)
    fixture.predictions.each { |prediction| PredictionScorer.score(prediction) }
  end
end
