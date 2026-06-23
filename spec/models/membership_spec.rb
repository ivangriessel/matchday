require "rails_helper"

RSpec.describe Membership, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
  end

  describe "validations" do
    subject { create(:membership) }

    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:group_id).with_message("is already a member of this group") }
  end

  describe "role enum" do
    it "defaults to member" do
      expect(create(:membership).role).to eq("member")
    end

    it "can be set to admin" do
      expect(create(:membership, :admin).role).to eq("admin")
    end

    it "rejects invalid roles" do
      expect { build(:membership, role: "superuser") }.to raise_error(ArgumentError)
    end
  end
end
