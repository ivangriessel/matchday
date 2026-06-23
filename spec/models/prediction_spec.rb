require "rails_helper"

RSpec.describe Prediction, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:fixture) }
  end

  describe "validations" do
    subject { build(:prediction) }

    it { is_expected.to validate_presence_of(:home_score) }
    it { is_expected.to validate_presence_of(:away_score) }
    it { is_expected.to validate_numericality_of(:home_score).only_integer.is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:away_score).only_integer.is_greater_than_or_equal_to(0) }

    it "rejects a second prediction from the same user for the same fixture" do
      existing = create(:prediction)
      duplicate = build(:prediction, user: existing.user, fixture: existing.fixture)
      expect(duplicate).not_to be_valid
    end
  end

  describe "#locked?" do
    it "returns false when kickoff is in the future" do
      fixture = build(:fixture, kickoff_at: 1.hour.from_now)
      prediction = build(:prediction, fixture: fixture)
      expect(prediction.locked?).to be false
    end

    it "returns true when kickoff has passed" do
      fixture = build(:fixture, :kicked_off)
      prediction = build(:prediction, fixture: fixture)
      expect(prediction.locked?).to be true
    end
  end

  describe "lock enforcement" do
    it "prevents creating a prediction after kickoff" do
      fixture = create(:fixture, :kicked_off)
      prediction = build(:prediction, fixture: fixture)
      expect(prediction).not_to be_valid
      expect(prediction.errors[:base]).to include("Predictions cannot be changed after kickoff")
    end

    it "prevents updating a prediction after kickoff" do
      prediction = create(:prediction)
      prediction.fixture.update!(kickoff_at: 1.minute.ago)
      prediction.home_score = 3
      expect(prediction).not_to be_valid
    end
  end

  describe "submitted_at" do
    it "is set automatically on save" do
      prediction = create(:prediction)
      expect(prediction.submitted_at).to be_within(2.seconds).of(Time.current)
    end
  end
end
