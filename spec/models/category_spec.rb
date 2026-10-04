require "rails_helper"

RSpec.describe Category, type: :model do
  before { @category = Category.new(name: "Category Name") }

  subject { @category }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:visible) }
  it { is_expected.to respond_to(:internal) }
  it { is_expected.to respond_to(:position) }
  it { is_expected.to respond_to(:new_position) }

  it { is_expected.to have_many(:projects).dependent(:destroy) }
  it { is_expected.to have_many(:issues).through(:projects) }
  it { is_expected.to have_many(:tasks).through(:projects) }
  it { is_expected.to have_many(:search_subscriptions).dependent(:destroy) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(200) }

  describe "validate #new_position_numericality" do
    let(:category) { Fabricate(:category) }

    context "when nil" do
      before { category.new_position = nil }

      it { expect(category).to be_valid }
    end

    context "when blank" do
      before { category.new_position = "" }

      it { expect(category).to be_valid }
    end

    context "when string" do
      before { category.new_position = "something" }

      it { expect(category).not_to be_valid }
    end

    context "when 0" do
      before { category.new_position = 0 }

      it { expect(category).not_to be_valid }
    end

    context "when 1" do
      before do
        category.new_position = 1
      end

      it { expect(category).to be_valid }
    end

    context "when two categories" do
      before do
        Fabricate(:category)
        category
        Fabricate(:category)
      end

      context "and given 1" do
        before { category.new_position = 1 }

        it { expect(category).to be_valid }
      end

      context "and given 3" do
        before { category.new_position = 3 }

        it { expect(category).to be_valid }
      end

      context "and given 4" do
        before { category.new_position = 4 }

        it { expect(category).not_to be_valid }
      end
    end
  end

  # CLASS

  describe ".all_visible" do
    before { Fabricate(:invisible_category) }

    it "returns categories with true visible" do
      category = Fabricate(:category)
      expect(described_class.all_visible).to eq([category])
    end
  end

  describe ".all_invisible" do
    before { Fabricate(:category) }

    it "returns categories with false visible" do
      category = Fabricate(:invisible_category)
      expect(described_class.all_invisible).to eq([category])
    end
  end

  # INSTANCE

  describe "#name_and_tag" do
    context "when category is visible" do
      let(:category) { Fabricate(:category) }

      it "returns name only" do
        expect(category.name_and_tag).to eq(category.name)
      end
    end

    context "when category is internal" do
      let(:category) { Fabricate(:internal_category) }

      it "returns name and internal tag" do
        expect(category.name_and_tag).to eq("#{category.name} (internal)")
      end
    end

    context "when category is invisible" do
      let(:category) { Fabricate(:invisible_category) }

      it "returns name and archived tag" do
        expect(category.name_and_tag).to eq("#{category.name} (archived)")
      end
    end

    context "when category is invisible and internal" do
      let(:category) { Fabricate(:invisible_category, internal: true) }

      it "returns name and archived tag" do
        expect(category.name_and_tag)
          .to eq("#{category.name} (archived, internal)")
      end
    end

    context "when category is visible, but missing name" do
      let(:category) { Fabricate(:category) }

      before { category.name = nil }

      it "returns string" do
        expect(category.name_and_tag).to eq("")
      end
    end
  end

  describe "#reposition" do
    let!(:first) { Fabricate(:category) }
    let!(:second) { Fabricate(:category) }
    let!(:third) { Fabricate(:category) }

    context "when new_position is 1" do
      before do
        third.new_position = 1
      end

      it "sorts category to first position" do
        expect do
          third.reposition
          third.reload
        end.to change(third, :position).from(3).to(1)
      end

      it "returns true" do
        expect(third.reposition).to be_truthy
      end
    end

    context "when new_position is 3" do
      before do
        second.new_position = 3
      end

      it "sorts category to third position" do
        expect do
          second.reposition
          second.reload
        end.to change(second, :position).from(2).to(3)
      end

      it "moves other categories" do
        expect do
          second.reposition
          third.reload
        end.to change(third, :position).from(3).to(2)
      end

      it "returns true" do
        expect(second.reposition).to be_truthy
      end
    end

    context "when first category and new_position is 1" do
      before do
        first.new_position = 1
      end

      it "doesn't change the category" do
        expect do
          first.reposition
          first.reload
        end.not_to change(first, :position)
      end

      it "returns false" do
        expect(first.reposition).to be_falsy
      end
    end

    context "when new_position is too large" do
      before do
        first.new_position = 10
      end

      it "doesn't change the category" do
        expect do
          first.reposition
          first.reload
        end.not_to change(first, :position)
      end

      it "returns false" do
        expect(first.reposition).to be_falsy
      end
    end

    context "when new_position is 0" do
      before do
        third.new_position = 0
      end

      it "doesn't change the category" do
        expect do
          third.reposition
          third.reload
        end.not_to change(third, :position)
      end

      it "returns false" do
        expect(third.reposition).to be_falsy
      end
    end

    context "when new_position is nil" do
      before do
        third.new_position = nil
      end

      it "doesn't change the category" do
        expect do
          third.reposition
          third.reload
        end.not_to change(third, :position)
      end

      it "returns false" do
        expect(third.reposition).to be_falsy
      end
    end
  end

  describe "#projects_except" do
    let(:category) { Fabricate(:category) }
    let(:different_project) { Fabricate(:project) }

    context "when category has no projects" do
      context "and not given a project" do
        it "returns none" do
          expect(category.projects_except).to eq([])
        end
      end

      context "and given a project" do
        it "returns none" do
          expect(category.projects_except(different_project)).to eq([])
        end
      end
    end

    context "when category has projects" do
      let!(:project) { Fabricate(:project, category: category) }

      context "and not given a project" do
        it "returns all category's projects" do
          expect(category.projects_except).to eq([project])
        end
      end

      context "and given a different project" do
        it "returns all category's projects" do
          expect(category.projects_except(different_project)).to eq([project])
        end
      end

      context "and given the category's project" do
        it "returns none" do
          expect(category.projects_except(project)).to eq([])
        end
      end
    end
  end
end
