require "rails_helper"

RSpec.describe Team, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:home_fixtures).dependent(:destroy) }
    it { is_expected.to have_many(:away_fixtures).dependent(:destroy) }
  end

  describe "validations" do
    subject { create(:team) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:short_code) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:short_code) }
  end
end
