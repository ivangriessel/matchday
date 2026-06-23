require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:groups).through(:memberships) }
    it { is_expected.to have_many(:predictions).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it "rejects invalid email formats" do
      expect(build(:user, email: "not-an-email")).not_to be_valid
    end
  end

  describe "email normalisation" do
    it "downcases and strips email before saving" do
      user = create(:user, email: "  Simon@Example.COM  ")
      expect(user.reload.email).to eq("simon@example.com")
    end
  end
end
