require "rails_helper"

RSpec.describe "Admin::Teams", type: :request do
  let(:app_admin) { create(:user, :app_admin) }
  let(:regular_user) { create(:user) }

  describe "authorisation" do
    it "redirects unauthenticated requests to sign-in" do
      get admin_teams_path
      expect(response).to redirect_to(auth_sign_in_path)
    end

    it "redirects non-admin users to root" do
      sign_in_as(regular_user)
      get admin_teams_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /admin/teams" do
    it "lists teams for app admins" do
      sign_in_as(app_admin)
      team = create(:team)
      get admin_teams_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(team.name)
    end
  end

  describe "POST /admin/teams" do
    before { sign_in_as(app_admin) }

    it "creates a team with valid params" do
      expect {
        post admin_teams_path, params: { team: { name: "Arsenal", short_code: "ARS" } }
      }.to change(Team, :count).by(1)
      expect(response).to redirect_to(admin_teams_path)
    end

    it "re-renders the form with invalid params" do
      post admin_teams_path, params: { team: { name: "", short_code: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /admin/teams/:id" do
    before { sign_in_as(app_admin) }

    it "updates the team" do
      team = create(:team)
      patch admin_team_path(team), params: { team: { name: "Updated FC" } }
      expect(team.reload.name).to eq("Updated FC")
      expect(response).to redirect_to(admin_teams_path)
    end
  end

  describe "DELETE /admin/teams/:id" do
    before { sign_in_as(app_admin) }

    it "deletes the team" do
      team = create(:team)
      expect {
        delete admin_team_path(team)
      }.to change(Team, :count).by(-1)
      expect(response).to redirect_to(admin_teams_path)
    end
  end
end
