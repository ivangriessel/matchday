require "rails_helper"

RSpec.describe "Admin::Fixtures", type: :request do
  let(:app_admin) { create(:user, :app_admin) }
  let(:regular_user) { create(:user) }

  describe "authorisation" do
    it "redirects unauthenticated requests to sign-in" do
      get admin_fixtures_path
      expect(response).to redirect_to(auth_sign_in_path)
    end

    it "redirects non-admin users to root" do
      sign_in_as(regular_user)
      get admin_fixtures_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /admin/fixtures" do
    it "lists fixtures for app admins" do
      sign_in_as(app_admin)
      fixture = create(:fixture)
      get admin_fixtures_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(fixture.home_team.name)
    end
  end

  describe "POST /admin/fixtures" do
    before { sign_in_as(app_admin) }

    let(:home_team) { create(:team) }
    let(:away_team) { create(:team) }
    let(:valid_params) do
      {
        fixture: {
          season: "2025-26",
          matchweek: 1,
          home_team_id: home_team.id,
          away_team_id: away_team.id,
          kickoff_at: 1.week.from_now,
          status: "scheduled"
        }
      }
    end

    it "creates a fixture with valid params" do
      expect {
        post admin_fixtures_path, params: valid_params
      }.to change(Fixture, :count).by(1)
      expect(response).to redirect_to(admin_fixtures_path)
    end

    it "re-renders the form with invalid params" do
      post admin_fixtures_path, params: { fixture: { season: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /admin/fixtures/:id" do
    before { sign_in_as(app_admin) }

    it "updates the fixture" do
      fixture = create(:fixture)
      patch admin_fixture_path(fixture), params: { fixture: { matchweek: 5 } }
      expect(fixture.reload.matchweek).to eq(5)
      expect(response).to redirect_to(admin_fixtures_path)
    end

    it "allows entering a result" do
      fixture = create(:fixture, :finished)
      patch admin_fixture_path(fixture), params: {
        fixture: { home_score: 2, away_score: 1 }
      }
      expect(fixture.reload.home_score).to eq(2)
    end
  end

  describe "DELETE /admin/fixtures/:id" do
    before { sign_in_as(app_admin) }

    it "deletes the fixture" do
      fixture = create(:fixture)
      expect {
        delete admin_fixture_path(fixture)
      }.to change(Fixture, :count).by(-1)
    end
  end
end
