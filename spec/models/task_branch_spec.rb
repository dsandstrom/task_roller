require "rails_helper"

RSpec.describe TaskBranch, type: :model do
  let(:project) { Fabricate(:project) }
  let(:source_task) { Fabricate(:task, project: project) }
  let(:target) { Fabricate(:task, project: project) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @task_branch = described_class.new(source_task_id: source_task.id,
                                       target_id: target.id,
                                       user_id: user.id)
  end

  subject { @task_branch }

  it { is_expected.to respond_to(:source_issue_id) }
  it { is_expected.to respond_to(:source_task_id) }
  it { is_expected.to respond_to(:target_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:issue_comment_id) }
  it { is_expected.to respond_to(:task_comment_id) }

  it { is_expected.to belong_to(:source_issue).optional }
  it { is_expected.to belong_to(:source_task).optional }
  it { is_expected.to belong_to(:issue_comment).optional }
  it { is_expected.to belong_to(:task_comment).optional }
  it { is_expected.to belong_to(:target).required }
  it { is_expected.to belong_to(:user).required }

  it { is_expected.to be_valid }

  describe "#validates" do
    context "source_issue_or_task" do
      before do
        subject.source_issue_id = nil
        subject.source_task_id = nil
      end

      describe "when source_issue" do
        it "should be valid" do
          subject.source_issue_id = Fabricate(:issue).id
          is_expected.to be_valid
        end
      end

      describe "when source_task" do
        it "should be valid" do
          subject.source_task_id = Fabricate(:task).id
          is_expected.to be_valid
        end
      end

      describe "when source_issue and source_task" do
        it "should not be valid" do
          subject.source_issue_id = Fabricate(:issue).id
          subject.source_task_id = Fabricate(:task).id
          is_expected.not_to be_valid
        end
      end

      describe "when no source_issue or source_task" do
        it "should not be valid" do
          is_expected.not_to be_valid
        end
      end
    end
  end

  describe "#new_target_attrs" do
    context "when no source" do
      let(:task_branch) do
        Fabricate.build(:task_branch, source_issue: nil, source_task: nil)
      end

      it "returns nil" do
        expect(task_branch.new_target_attrs).to eq({})
      end
    end

    context "when source_issue" do
      let(:source_issue) { Fabricate(:issue) }
      let(:issue_comment) { Fabricate(:issue_comment, issue: source_issue) }
      let(:task_comment) { Fabricate(:task_comment) }

      context "without an issue_comment" do
        let(:task_branch) do
          Fabricate(:task_branch_from_issue, source_issue: source_issue)
        end

        let(:summary) do
          "#{source_issue.summary} (Copied from Issue##{source_issue.id})"
        end

        let(:description) do
          "(Copied from Issue##{source_issue.id})\n\n---\n\n" \
            "#{source_issue.description}\n\n---\n"
        end

        it "returns summary and description" do
          expect(task_branch.new_target_attrs)
            .to eq({ summary: summary, description: description })
        end
      end

      context "with issue_comment" do
        let(:task_branch) do
          Fabricate(:task_branch_from_issue, source_issue: source_issue,
                                             issue_comment: issue_comment)
        end

        let(:summary) do
          "#{source_issue.summary} (Copied from Issue##{source_issue.id})"
        end

        let(:description) do
          "(Copied from comment by #{issue_comment.user.name} in " \
            "Issue##{source_issue.id})\n\n---\n\n" \
            "#{issue_comment.body}\n\n---\n"
        end

        it "returns summary and description" do
          expect(task_branch.new_target_attrs)
            .to eq({ summary: summary, description: description })
        end
      end

      context "with task_comment" do
        let(:task_branch) do
          Fabricate(:task_branch_from_issue, source_issue: source_issue,
                                             task_comment: task_comment)
        end

        let(:summary) do
          "#{source_issue.summary} (Copied from Issue##{source_issue.id})"
        end

        let(:description) do
          "(Copied from Issue##{source_issue.id})\n\n---\n\n" \
            "#{source_issue.description}\n\n---\n"
        end

        it "returns summary and description" do
          expect(task_branch.new_target_attrs)
            .to eq({ summary: summary, description: description })
        end
      end
    end

    context "when source_task" do
      let(:source_task) { Fabricate(:task) }
      let(:task_comment) { Fabricate(:task_comment, task: source_task) }
      let(:issue_comment) { Fabricate(:issue_comment) }

      context "without an task_comment" do
        let(:task_branch) do
          Fabricate(:task_branch_from_task, source_task: source_task)
        end

        let(:summary) do
          "#{source_task.summary} (Copied from Task##{source_task.id})"
        end

        let(:description) do
          "(Copied from Task##{source_task.id})\n\n---\n\n" \
            "#{source_task.description}\n\n---\n"
        end

        it "returns summary and description" do
          expect(task_branch.new_target_attrs)
            .to eq({ summary: summary, description: description })
        end
      end

      context "with task_comment" do
        let(:task_branch) do
          Fabricate(:task_branch_from_task, source_task: source_task,
                                            task_comment: task_comment)
        end

        let(:summary) do
          "#{source_task.summary} (Copied from Task##{source_task.id})"
        end

        let(:description) do
          "(Copied from comment by #{task_comment.user.name} in " \
            "Task##{source_task.id})\n\n---\n\n" \
            "#{task_comment.body}\n\n---\n"
        end

        it "returns summary and description" do
          expect(task_branch.new_target_attrs)
            .to eq({ summary: summary, description: description })
        end
      end

      context "with issue_comment" do
        let(:task_branch) do
          Fabricate(:task_branch_from_task, source_task: source_task,
                                            issue_comment: issue_comment)
        end

        let(:summary) do
          "#{source_task.summary} (Copied from Task##{source_task.id})"
        end

        let(:description) do
          "(Copied from Task##{source_task.id})\n\n---\n\n" \
            "#{source_task.description}\n\n---\n"
        end

        it "returns summary and description" do
          expect(task_branch.new_target_attrs)
            .to eq({ summary: summary, description: description })
        end
      end

      context "with an issue_id" do
        let(:source_task) { Fabricate(:task, project: project, issue: issue) }

        let(:summary) do
          "#{source_task.summary} (Copied from Task##{source_task.id})"
        end

        let(:description) do
          "(Copied from Task##{source_task.id})\n\n---\n\n" \
            "#{source_task.description}\n\n---\n"
        end

        context "from an closed issue" do
          let(:issue) { Fabricate(:issue, project: project) }

          let(:task_branch) do
            Fabricate(:task_branch_from_task, source_task: source_task)
          end

          it "returns issue_id" do
            expect(task_branch.new_target_attrs)
              .to eq({ summary: summary, description: description,
                       issue_id: issue.id })
          end
        end

        context "from an closed issue" do
          let(:issue) { Fabricate(:addressed_issue, project: project) }

          let(:task_branch) do
            Fabricate(:task_branch_from_task, source_task: source_task)
          end

          it "returns without issue_id" do
            expect(task_branch.new_target_attrs)
              .to eq({ summary: summary, description: description })
          end
        end
      end
    end
  end
end
