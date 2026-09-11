require "rails_helper"

RSpec.describe IssueBranch, type: :model do
  let(:project) { Fabricate(:project) }
  let(:source_issue) { Fabricate(:issue, project: project) }
  let(:target) { Fabricate(:issue, project: project) }
  let(:user) { Fabricate(:user_reviewer) }

  before do
    @issue_branch = described_class.new(source_issue_id: source_issue.id,
                                        target_id: target.id,
                                        user_id: user.id)
  end

  subject { @issue_branch }

  it { is_expected.to respond_to(:source_issue_id) }
  it { is_expected.to respond_to(:target_id) }
  it { is_expected.to respond_to(:user_id) }

  it { is_expected.to belong_to(:source_issue).optional }
  it { is_expected.to belong_to(:source_task).optional }
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
end
