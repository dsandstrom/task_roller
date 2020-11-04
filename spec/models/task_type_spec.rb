# frozen_string_literal: true

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
    context "when 'up'" do
      it "sorts task_type up one" do
        _first = Fabricate(:task_type)
        _second = Fabricate(:task_type)
        third = Fabricate(:task_type)

        expect do
          third.reposition("up")
        end.to change(third, :position).from(3).to(2)
      end

      it "returns true" do
        _first = Fabricate(:task_type)
        _second = Fabricate(:task_type)
        third = Fabricate(:task_type)

        expect(third.reposition("up")).to be_truthy
      end
    end

    context "when 'down'" do
      it "sorts task_type up one" do
        first = Fabricate(:task_type)
        _second = Fabricate(:task_type)
        _third = Fabricate(:task_type)

        expect do
          first.reposition("down")
        end.to change(first, :position).from(1).to(2)
      end

      it "returns true" do
        first = Fabricate(:task_type)
        _second = Fabricate(:task_type)
        _third = Fabricate(:task_type)

        expect(first.reposition("down")).to be_truthy
      end
    end

    context "when 'something else'" do
      it "doesn't change the task_type" do
        first = Fabricate(:task_type)
        _second = Fabricate(:task_type)
        _third = Fabricate(:task_type)

        expect do
          first.reposition("something else")
        end.not_to change(first, :position)
      end

      it "returns false" do
        first = Fabricate(:task_type)
        _second = Fabricate(:task_type)
        _third = Fabricate(:task_type)

        expect(first.reposition("something else")).to be_falsy
      end
    end
  end
end
