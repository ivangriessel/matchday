require "rails_helper"

RSpec.describe Fixture, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:home_team).class_name("Team") }
    it { is_expected.to belong_to(:away_team).class_name("Team") }
    it { is_expected.to have_many(:predictions).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:fixture) }

    it { is_expected.to validate_presence_of(:season) }
    it { is_expected.to validate_presence_of(:gameweek) }
    it { is_expected.to validate_presence_of(:kickoff_at) }
    it { is_expected.to validate_numericality_of(:gameweek).only_integer.is_greater_than(0) }

    it "rejects a fixture where home and away team are the same" do
      team = create(:team)
      fixture = build(:fixture, home_team: team, away_team: team)
      expect(fixture).not_to be_valid
      expect(fixture.errors[:away_team]).to include("must differ from home team")
    end
  end

  describe "status enum" do
    it "defaults to scheduled" do
      expect(create(:fixture).status).to eq("scheduled")
    end

    it "transitions through valid statuses" do
      fixture = create(:fixture)
      fixture.finished!
      expect(fixture.reload.status).to eq("finished")
    end
  end

  describe "scopes" do
    it ".for_gameweek returns fixtures in kickoff order for that week" do
      gw1_later  = create(:fixture, gameweek: 1, kickoff_at: 2.weeks.from_now)
      gw1_first  = create(:fixture, gameweek: 1, kickoff_at: 1.week.from_now)
      _gw2       = create(:fixture, gameweek: 2, kickoff_at: 3.weeks.from_now)

      expect(Fixture.for_gameweek(1)).to eq([ gw1_first, gw1_later ])
    end

    it ".upcoming returns only scheduled fixtures ordered by kickoff" do
      upcoming   = create(:fixture, :scheduled)
      _finished  = create(:fixture, :finished)

      expect(Fixture.upcoming).to eq([ upcoming ])
    end
  end
end
