require "rails_helper"

RSpec.describe "Fixtures", type: :request do
  let(:user) { create(:user) }

  describe "GET /" do
    it "redirects unauthenticated visitors to sign-in" do
      get root_path
      expect(response).to redirect_to(auth_sign_in_path)
    end

    context "when signed in" do
      before { sign_in_as(user) }

      it "shows the current matchweek heading" do
        create(:fixture, matchweek: 3)
        get root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Matchweek 3")
      end

      it "shows each fixture's teams" do
        fixture = create(:fixture, matchweek: 1)
        get root_path
        expect(response.body).to include(fixture.home_team.name)
        expect(response.body).to include(fixture.away_team.name)
      end

      it "shows the result for finished fixtures within the current matchweek" do
        create(:fixture, :finished, matchweek: 1, home_score: 2, away_score: 1)
        create(:fixture, matchweek: 1, kickoff_at: 1.day.from_now)
        get root_path
        expect(response.body).to include("2–1")
      end

      it "shows the current matchweek, not a completed one" do
        create(:fixture, :finished, matchweek: 1)
        create(:fixture, matchweek: 2)
        get root_path
        expect(response.body).to include("Matchweek 2")
        expect(response.body).not_to include("Matchweek 1")
      end

      it "shows a message when there are no upcoming fixtures" do
        get root_path
        expect(response.body).to include("No upcoming fixtures")
      end

      it "shows the user's points for a scored fixture" do
        fixture = create(:fixture, :kicked_off, matchweek: 1, kickoff_at: 1.hour.ago)
        prediction = build(:prediction, user: user, fixture: fixture, home_score: 1, away_score: 0, points: 5)
        prediction.save!(validate: false)
        create(:fixture, matchweek: 1, kickoff_at: 1.day.from_now)
        get root_path
        expect(response.body).to include("5 pts")
      end

      it "shows the matchweek points total when any fixture is scored" do
        fixture = create(:fixture, :kicked_off, matchweek: 1, kickoff_at: 1.hour.ago)
        prediction = build(:prediction, user: user, fixture: fixture, home_score: 1, away_score: 0, points: 2)
        prediction.save!(validate: false)
        create(:fixture, matchweek: 1, kickoff_at: 1.day.from_now)
        get root_path
        expect(response.body).to include("Matchweek total")
        expect(response.body).to include("2 pts")
      end
    end
  end
end
