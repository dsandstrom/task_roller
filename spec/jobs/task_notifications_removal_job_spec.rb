require "rails_helper"

RSpec.describe TaskNotificationsRemovalJob, type: :job do
  subject { described_class }

  let(:task) { Fabricate(:task) }
  let(:user) { Fabricate(:user) }

  describe "#perform" do
    context "when given an Task and User" do
      context "with a notification" do
        before do
          Fabricate(:task_notification, task: task, user: user)
        end

        it "destroys it" do
          expect do
            subject.perform_now task, user
          end.to change(TaskNotification, :count).by(-1)
        end
      end

      context "with multiple notifications" do
        before do
          Fabricate(:task_notification, task: task, user: user)
          Fabricate(:task_notification, task: task, user: user)
        end

        it "destroys them all" do
          expect do
            subject.perform_now task, user
          end.to change(TaskNotification, :count).by(-2)
        end
      end

      context "without a notification" do
        it "doesn't destroy any" do
          expect do
            subject.perform_now task, user
          end.not_to change(TaskNotification, :count)
        end

        it "doesn't raise an error" do
          expect do
            subject.perform_now task, user
          end.not_to raise_error
        end
      end
    end
  end
end
