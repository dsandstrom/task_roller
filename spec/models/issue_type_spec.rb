require "rails_helper"

RSpec.describe IssueType, type: :model do
  let(:color_options) { %w[green yellow red brown default blue purple] }
  let(:icon_options) { IconFileReader.new.options }

  before do
    @issue_type =
      IssueType.new(name: "Issue Type Name", icon: "bug", color: "red")
  end

  subject { @issue_type }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:icon) }
  it { is_expected.to respond_to(:color) }
  it { is_expected.to respond_to(:position) }
  it { is_expected.to respond_to(:new_position) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of(:icon) }
  it { is_expected.to validate_inclusion_of(:icon).in_array(icon_options) }
  it { is_expected.to validate_presence_of(:color) }
  it { is_expected.to validate_inclusion_of(:color).in_array(color_options) }

  describe "validate #new_position_numericality" do
    let(:issue_type) { Fabricate(:issue_type) }

    context "when nil" do
      before { issue_type.new_position = nil }

      it { expect(issue_type).to be_valid }
    end

    context "when blank" do
      before { issue_type.new_position = "" }

      it { expect(issue_type).to be_valid }
    end

    context "when string" do
      before { issue_type.new_position = "something" }

      it { expect(issue_type).not_to be_valid }
    end

    context "when 0" do
      before { issue_type.new_position = 0 }

      it { expect(issue_type).not_to be_valid }
    end

    context "when 1" do
      before do
        issue_type.new_position = 1
      end

      it { expect(issue_type).to be_valid }
    end

    context "when two categories" do
      before do
        Fabricate(:issue_type)
        issue_type
        Fabricate(:issue_type)
      end

      context "and given 1" do
        before { issue_type.new_position = 1 }

        it { expect(issue_type).to be_valid }
      end

      context "and given 3" do
        before { issue_type.new_position = 3 }

        it { expect(issue_type).to be_valid }
      end

      context "and given 4" do
        before { issue_type.new_position = 4 }

        it { expect(issue_type).not_to be_valid }
      end
    end
  end

  describe ".default_scope" do
    it "orders by position" do
      second = Fabricate(:issue_type)
      first = Fabricate(:issue_type)
      first.move_to_top

      expect(IssueType.all).to eq([first, second])
    end
  end

  describe "#reposition" do
    let!(:first) { Fabricate(:issue_type) }
    let!(:second) { Fabricate(:issue_type) }
    let!(:third) { Fabricate(:issue_type) }

    before { Fabricate(:task_type) }

    context "when new_position is 1" do
      before do
        third.new_position = 1
      end

      it "sorts issue_type to first position" do
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

      it "sorts issue_type to third position" do
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

    context "when first issue_type and new_position is 1" do
      before do
        first.new_position = 1
      end

      it "doesn't change the issue_type" do
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

      it "doesn't change the issue_type" do
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

      it "doesn't change the issue_type" do
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

      it "doesn't change the issue_type" do
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

  describe "#any_issues?" do
    context "when IssueType has no issues" do
      let(:issue_type) { Fabricate(:issue_type) }

      before { Fabricate(:issue) }

      it "returns false" do
        expect(issue_type.any_issues?).to eq(false)
      end
    end

    context "when IssueType has an issue" do
      let(:issue_type) { Fabricate(:issue_type) }

      before { Fabricate(:issue, issue_type: issue_type) }

      it "returns true" do
        expect(issue_type.any_issues?).to eq(true)
      end
    end
  end
end
