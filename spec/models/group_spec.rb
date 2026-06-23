require "rails_helper"

RSpec.describe Group, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:memberships) }
  end

  describe "validations" do
    subject { create(:group) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }

    it "rejects slugs with uppercase or spaces" do
      expect(build(:group, slug: "My Group")).not_to be_valid
    end
  end

  describe "slug generation" do
    it "generates a slug from name on create" do
      group = create(:group, name: "The Lads", slug: nil)
      expect(group.slug).to eq("the-lads")
    end

    it "does not overwrite a slug that was explicitly set" do
      group = create(:group, name: "The Lads", slug: "custom-slug")
      expect(group.slug).to eq("custom-slug")
    end
  end
end
