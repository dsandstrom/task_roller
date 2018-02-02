# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskType, type: :model do
  before do
    @task_type =
      TaskType.new(name: "Task Type Name", icon: "bulb", color: "blue")
  end

  subject { @task_type }

  it { is_expected.to be_a(RollerType) }
  it { expect(subject.type).to eq("TaskType") }
  it { is_expected.to be_valid }

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
