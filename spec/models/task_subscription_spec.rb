require "rails_helper"

RSpec.describe TaskSubscription, type: :model do
  let(:task) { Fabricate(:task) }
  let(:user) { Fabricate(:user_reporter) }

  before do
    @task_subscription = TaskSubscription.new(user_id: user.id,
                                              task_id: task.id)
  end

  subject { @task_subscription }

  it { is_expected.to be_valid }
  it { is_expected.to respond_to(:heading) }

  it { is_expected.to belong_to(:task).required }
  it { is_expected.to belong_to(:user).required }

  context "when a duplicate" do
    it "shouldn't be valid" do
      subject.dup.save
      expect(subject).not_to be_valid
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task) }

  describe "#toggle" do
    context "for an active TaskSubscription" do
      let(:task_subscription) { Fabricate(:task_subscription) }

      it "changes active to false" do
        expect do
          task_subscription.toggle
          task_subscription.reload
        end.to change(task_subscription, :active).to(false)
      end
    end

    context "for an inactive TaskSubscription" do
      let(:task_subscription) { Fabricate(:inactive_task_subscription) }

      it "changes active to true" do
        expect do
          task_subscription.toggle
          task_subscription.reload
        end.to change(task_subscription, :active).to(true)
      end
    end
  end
end
