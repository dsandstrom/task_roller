# frozen_string_literal: true

require "rails_helper"

RSpec.describe RepoCallout, type: :model do
  let(:user) { Fabricate(:user) }
  let(:task) { Fabricate(:task) }

  before do
    @repo_callout =
      RepoCallout.new(task_id: task.id, user_id: user.id, action: "complete",
                      commit_sha: "zzzyyyxxxx", commit_message: "Fixes #12")
  end

  subject { @repo_callout }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:github_commit_id) }
  it { is_expected.to respond_to(:commit_html_url) }

  it { is_expected.to validate_presence_of(:task_id) }
  it { is_expected.to validate_presence_of(:action) }
  it { is_expected.to validate_presence_of(:commit_sha) }
  it { is_expected.to validate_presence_of(:commit_message) }

  it { is_expected.to validate_uniqueness_of(:task_id).scoped_to(:commit_sha) }

  it do
    is_expected.to validate_inclusion_of(:action)
      .in_array(%w[start pause complete])
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task) }

  describe "#process_commit_message" do
    context "when no action and task_id" do
      before do
        subject.action = nil
        subject.task_id = nil
      end

      context "when no commit message" do
        before { subject.commit_message = "" }

        it "doesn't change action" do
          expect do
            subject.process_commit_message
          end.not_to change(subject, :action)
        end

        it "doesn't change task_id" do
          expect do
            subject.process_commit_message
          end.not_to change(subject, :task_id)
        end
      end

      context "when commit_message" do
        context "is 'Starts Task#id'" do
          before { subject.commit_message = "Starts Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("start")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'start Task#id'" do
          before { subject.commit_message = "start Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("start")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Pauses Task#id'" do
          before { subject.commit_message = "Pauses Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("pause")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Pause Task#id'" do
          before { subject.commit_message = "Pause Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("pause")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Paused Task#id'" do
          before { subject.commit_message = "Paused Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("pause")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Fixed Task#id'" do
          before { subject.commit_message = "Fixes Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("complete")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Fix Task#id'" do
          before { subject.commit_message = "Fix Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("complete")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Fixes Task#id'" do
          before { subject.commit_message = "Fixes Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("complete")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Closes Task#id'" do
          before { subject.commit_message = "Closes Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("complete")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Completes Task#id'" do
          before { subject.commit_message = "Completes Task##{task.id}" }

          it "changes action" do
            expect do
              subject.process_commit_message
            end.to change(subject, :action).to("complete")
          end

          it "changes task_id" do
            expect do
              subject.process_commit_message
            end.to change(subject, :task_id).to(task.id)
          end
        end

        context "is 'Starts Task#'" do
          before { subject.commit_message = "Starts Task#" }

          it "doesn't change action" do
            expect do
              subject.process_commit_message
            end.not_to change(subject, :action)
          end

          it "doesn't change task_id" do
            expect do
              subject.process_commit_message
            end.not_to change(subject, :task_id)
          end
        end

        context "is 'Task#id'" do
          before { subject.commit_message = "Task##{task.id}" }

          it "doesn't change action" do
            expect do
              subject.process_commit_message
            end.not_to change(subject, :action)
          end

          it "doesn't change task_id" do
            expect do
              subject.process_commit_message
            end.not_to change(subject, :task_id)
          end
        end
      end
    end

    context "when action and task_id" do
      before do
        subject.action = "complete"
        subject.task_id = Fabricate(:task).id
      end

      before { subject.commit_message = "Starts Task##{task.id}" }

      it "doesn't change action" do
        expect do
          subject.process_commit_message
        end.not_to change(subject, :action)
      end

      it "doesn't change task_id" do
        expect do
          subject.process_commit_message
        end.not_to change(subject, :task_id)
      end
    end
  end
end
