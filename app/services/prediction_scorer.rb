class PredictionScorer
  def self.score(prediction)
    new(prediction).score
  end

  def initialize(prediction)
    @prediction = prediction
    @fixture = prediction.fixture
  end

  def score
    if result_available?
      @prediction.update_column(:points, calculate_points)
    else
      @prediction.update_column(:points, nil)
    end
  end

  private

  def result_available?
    @fixture.home_score.present? && @fixture.away_score.present?
  end

  def calculate_points
    if exact_score?
      5
    elsif correct_outcome?
      2
    else
      0
    end
  end

  def exact_score?
    @prediction.home_score == @fixture.home_score &&
      @prediction.away_score == @fixture.away_score
  end

  def correct_outcome?
    outcome(@prediction.home_score, @prediction.away_score) ==
      outcome(@fixture.home_score, @fixture.away_score)
  end

  def outcome(home, away)
    if home > away then :home_win
    elsif away > home then :away_win
    else :draw
    end
  end
end
