require "rails_helper"

RSpec.describe TaskType, type: :model do
  let(:color_options) { %w[green yellow red brown default blue purple] }
  let(:icon_options) { IconFileReader.new.options }

  before do
    @task_type =
      TaskType.new(name: "Task Type Name", icon: "bulb", color: "blue")
  end

  subject { @task_type }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:icon) }
  it { is_expected.to respond_to(:color) }
  it { is_expected.to respond_to(:position) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(100) }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  it { is_expected.to validate_presence_of(:icon) }
  it { is_expected.to validate_inclusion_of(:icon).in_array(icon_options) }
  it { is_expected.to validate_presence_of(:color) }
  it { is_expected.to validate_inclusion_of(:color).in_array(color_options) }

  describe "validate #new_position_numericality" do
    let(:task_type) { Fabricate(:task_type) }

    context "when nil" do
      before { task_type.new_position = nil }

      it { expect(task_type).to be_valid }
    end

    context "when blank" do
      before { task_type.new_position = "" }

      it { expect(task_type).to be_valid }
    end

    context "when string" do
      before { task_type.new_position = "something" }

      it { expect(task_type).not_to be_valid }
    end

    context "when 0" do
      before { task_type.new_position = 0 }

      it { expect(task_type).not_to be_valid }
    end

    context "when 1" do
      before do
        task_type.new_position = 1
      end

      it { expect(task_type).to be_valid }
    end

    context "when two categories" do
      before do
        Fabricate(:task_type)
        task_type
        Fabricate(:task_type)
      end

      context "and given 1" do
        before { task_type.new_position = 1 }

        it { expect(task_type).to be_valid }
      end

      context "and given 3" do
        before { task_type.new_position = 3 }

        it { expect(task_type).to be_valid }
      end

      context "and given 4" do
        before { task_type.new_position = 4 }

        it { expect(task_type).not_to be_valid }
      end
    end
  end

  describe ".default_scope" do
    it "orders by position" do
      Fabricate(:issue_type)
      second = Fabricate(:task_type)
      first = Fabricate(:task_type)
      first.move_to_top

      expect(TaskType.all).to eq([first, second])
    end
  end

  describe "#reposition" do
    let!(:first) { Fabricate(:task_type) }
    let!(:second) { Fabricate(:task_type) }
    let!(:third) { Fabricate(:task_type) }

    before { Fabricate(:issue_type) }

    context "when new_position is 1" do
      before do
        third.new_position = 1
      end

      it "sorts task_type to first position" do
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

      it "sorts task_type to third position" do
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

    context "when first task_type and new_position is 1" do
      before do
        first.new_position = 1
      end

      it "doesn't change the task_type" do
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

      it "doesn't change the task_type" do
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

      it "doesn't change the task_type" do
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

      it "doesn't change the task_type" do
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

  describe "#any_tasks?" do
    context "when TaskType has no tasks" do
      let(:task_type) { Fabricate(:task_type) }

      before { Fabricate(:task) }

      it "returns false" do
        expect(task_type.any_tasks?).to eq(false)
      end
    end

    context "when TaskType has an task" do
      let(:task_type) { Fabricate(:task_type) }

      before { Fabricate(:task, task_type: task_type) }

      it "returns true" do
        expect(task_type.any_tasks?).to eq(true)
      end
    end
  end
end
