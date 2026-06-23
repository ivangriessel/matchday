require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "sign-in page" do
    it "renders for unauthenticated visitors" do
      get auth_sign_in_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "protected routes" do
    it "redirects unauthenticated requests to sign-in" do
      get root_path
      expect(response).to redirect_to(auth_sign_in_path)
    end
  end

  describe "submitting an email" do
    context "when the user exists" do
      let!(:user) { create(:user) }

      it "creates a passwordless session and redirects to the check-email page" do
        post auth_sign_in_path, params: { passwordless: { email: user.email } }
        ps = Passwordless::Session.last
        expect(response).to redirect_to(verify_auth_sign_in_path(ps))
        expect(Passwordless::Session.count).to eq(1)
      end

      it "sends a magic link email" do
        expect {
          post auth_sign_in_path, params: { passwordless: { email: user.email } }
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end
    end

    context "when the email is not registered" do
      it "redirects back without creating a session" do
        post auth_sign_in_path, params: { passwordless: { email: "unknown@example.com" } }
        expect(Passwordless::Session.count).to eq(0)
      end
    end
  end

  describe "clicking the magic link" do
    let!(:user) { create(:user) }

    it "signs the user in and redirects to root" do
      sign_in_as(user)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(user.name)
    end
  end

  describe "sign out" do
    let!(:user) { create(:user) }

    it "clears the session so protected pages redirect to sign-in" do
      sign_in_as(user)
      delete auth_sign_out_path
      get root_path
      expect(response).to redirect_to(auth_sign_in_path)
    end
  end
end
