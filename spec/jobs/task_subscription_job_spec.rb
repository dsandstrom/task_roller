require "rails_helper"

RSpec.describe TaskSubscriptionJob, type: :job do
  let(:task) { Fabricate(:task) }
  let(:user) { Fabricate(:user_worker) }

  subject { described_class }

  describe "#perform" do
    context "when given task and user" do
      it "runs subscribe_user for task and user" do
        expect(task).to receive(:subscribe_user).with(user)

        subject.perform_now task, user
      end

      context "and send_new is false" do
        it "doesn't enqueue any jobs" do
          expect do
            subject.perform_now task, user, send_new: false
          end.not_to have_enqueued_job
        end
      end

      context "and send_new is true" do
        it "enqueues IssueNotifierJob for the task and user" do
          subject.perform_now task, user, send_new: true

          expect(TaskNotifierJob).to have_been_enqueued.exactly(:once)
          expect(TaskNotifierJob)
            .to have_been_enqueued.with(task, user, { event: "new" })
        end
      end
    end

    context "when not given task" do
      it "doesn't raise an error" do
        expect do
          subject.perform_now nil, user
        end.not_to raise_error
      end
    end

    context "when not given user" do
      it "doesn't raise an error" do
        expect do
          subject.perform_now task, nil
        end.not_to raise_error
      end

      it "doesn't run subscribe_user" do
        expect(task).not_to receive(:subscribe_user)

        subject.perform_now task, nil
      end
    end
  end
end
