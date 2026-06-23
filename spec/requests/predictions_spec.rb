require "rails_helper"

RSpec.describe "Predictions", type: :request do
  let(:user) { create(:user) }

  describe "POST /predictions" do
    it "redirects unauthenticated users to sign-in" do
      post predictions_path
      expect(response).to redirect_to(auth_sign_in_path)
    end

    context "when signed in" do
      before { sign_in_as(user) }

      let(:fixture) { create(:fixture, kickoff_at: 1.week.from_now) }

      it "creates predictions and redirects to root" do
        expect {
          post predictions_path, params: {
            predictions: { fixture.id => { home_score: 1, away_score: 2 } }
          }
        }.to change(Prediction, :count).by(1)
        expect(response).to redirect_to(root_path)
      end

      it "updates an existing prediction" do
        prediction = create(:prediction, user: user, fixture: fixture, home_score: 0, away_score: 0)
        post predictions_path, params: {
          predictions: { fixture.id => { home_score: 3, away_score: 1 } }
        }
        expect(prediction.reload.home_score).to eq(3)
        expect(prediction.reload.away_score).to eq(1)
      end

      it "ignores locked fixtures" do
        locked = create(:fixture, :kicked_off)
        expect {
          post predictions_path, params: {
            predictions: { locked.id => { home_score: 1, away_score: 0 } }
          }
        }.not_to change(Prediction, :count)
      end

      it "does nothing gracefully with no predictions params" do
        expect {
          post predictions_path
        }.not_to change(Prediction, :count)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
