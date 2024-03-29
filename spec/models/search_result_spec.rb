# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult, type: :model do
  before { @search_result = SearchResult.new }

  subject { @search_result }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:closed) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:opened_at) }
  it { is_expected.to respond_to(:type_id) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:issue_id) }
  it { is_expected.to respond_to(:class_name) }
  it { is_expected.to respond_to(:created_at) }
  it { is_expected.to respond_to(:updated_at) }

  it { is_expected.to belong_to(:user).required }
  it { is_expected.to belong_to(:project).required }
  it { is_expected.to respond_to(:category) }

  it { is_expected.to belong_to(:issue_type).optional }
  it { is_expected.to belong_to(:task_type).optional }

  it { is_expected.to belong_to(:issue).required }

  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignees) }
  it { is_expected.to have_many(:tasks) }

  # CLASS

  describe ".filter_by_string" do
    context "when no tasks" do
      it "returns []" do
        expect(SearchResult.filter_by_string("alpha")).to eq([])
      end
    end

    context "when tasks" do
      context "and query is ''" do
        let!(:task) { Fabricate(:task) }

        it "returns all tasks" do
          search_results = SearchResult.filter_by(query: "")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(task.id)
        end
      end

      context "and query matches an task's summary" do
        let!(:task) { Fabricate(:task, summary: "Alpha Beta Gamma") }

        before do
          Fabricate(:task, summary: "Beta Gamma")
        end

        it "returns one task" do
          search_results = SearchResult.filter_by(query: "alpha")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(task.id)
        end
      end

      context "and query matches an task's description" do
        let!(:task) { Fabricate(:task, description: "Alpha Beta Gamma") }

        before do
          Fabricate(:task, description: "Beta Gamma")
        end

        it "returns one task" do
          search_results = SearchResult.filter_by(query: "alpha")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(task.id)
        end
      end

      context "and query doesn't match an task" do
        before do
          Fabricate(:task, description: "Beta Gamma")
        end

        it "returns none" do
          expect(SearchResult.filter_by_string("alpha")).to eq([])
        end
      end

      context "and query matches one task's summary, another's description" do
        let!(:first_task) { Fabricate(:task, summary: "Alpha Beta Gamma") }
        let!(:second_task) do
          Fabricate(:task, description: "Alpha Beta Gamma")
        end

        before do
          Fabricate(:task, description: "Beta Gamma")
        end

        it "returns both tasks" do
          search_results = SearchResult.filter_by(query: "alpha")
          expect(search_results.count).to eq(2)

          assert search_results.any? do |search_result|
            search_result.id == first_task.id
          end
          assert search_results.any? do |search_result|
            search_result.id == second_task.id
          end
        end
      end
    end
  end

  describe ".filter_by_projects" do
    let(:project) { Fabricate(:project) }
    let!(:project_issue) { Fabricate(:issue, project: project) }
    let!(:wrong_project_issue) { Fabricate(:issue) }

    context "when given nil" do
      it "returns all" do
        expect(SearchResult.filter_by_projects(nil).map(&:id))
          .to contain_exactly(project_issue.id, wrong_project_issue.id)
      end
    end

    context "when given ''" do
      it "returns all" do
        expect(SearchResult.filter_by_projects("").map(&:id))
          .to contain_exactly(project_issue.id, wrong_project_issue.id)
      end
    end

    context "when given []" do
      it "returns none" do
        expect(SearchResult.filter_by_projects([])).to eq([])
      end
    end

    context "when given a project id" do
      it "returns results from that project only" do
        expect(SearchResult.filter_by_projects([project.id]).map(&:id))
          .to contain_exactly(project_issue.id)
      end
    end
  end

  describe ".filter_by" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project, category: category) }

    context "when no search_results" do
      it "returns []" do
        expect(SearchResult.filter_by(order: "created,desc")).to eq([])
      end
    end

    context "when :query" do
      context "is ''" do
        let!(:task) { Fabricate(:task) }

        it "returns all search_results" do
          search_results = SearchResult.filter_by(query: "")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(task.id)
        end
      end

      context "is 'beta'" do
        let!(:task) { Fabricate(:task, summary: "Beta Problem") }

        before { Fabricate(:task) }

        it "returns matching search_results" do
          search_results = SearchResult.filter_by(query: "beta")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(task.id)
        end
      end

      context "is an issue id" do
        let!(:issue) { Fabricate(:issue) }

        before { Fabricate(:issue) }

        it "returns matching search_results" do
          search_results = SearchResult.filter_by(query: issue.id.to_s)
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(issue.id)
        end
      end

      context "is 'issue-123'" do
        let!(:issue) { Fabricate(:issue) }

        before { Fabricate(:issue) }

        it "returns matching search_results" do
          search_results = SearchResult.filter_by(query: "issue-#{issue.id}")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(issue.id)
        end
      end

      context "is 'issue#123'" do
        let!(:issue) { Fabricate(:issue) }

        before { Fabricate(:issue) }

        it "returns matching search_results" do
          search_results = SearchResult.filter_by(query: "issue##{issue.id}")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(issue.id)
        end
      end

      context "is 'issue #123'" do
        let!(:issue) { Fabricate(:issue) }
        let(:task) { Fabricate(:task) }

        before do
          Fabricate(:issue)
          Fabricate(:task, summary: "Task for Issue ##{issue.id}")
        end

        it "returns matching issues" do
          search_results = SearchResult.filter_by(query: "issue ##{issue.id}")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(issue.id)
        end

        it "returns matching tasks assigned to issue" do
          task.update issue_id: issue.id

          search_results = SearchResult.filter_by(query: "issue ##{issue.id}")
          expect(search_results.count).to eq(2)
          expect(search_results.map(&:id)).to contain_exactly(issue.id, task.id)
        end
      end

      context "is a task id" do
        let!(:task) { Fabricate(:task) }

        before { Fabricate(:task) }

        it "returns matching search_results" do
          search_results = SearchResult.filter_by(query: task.id.to_s)
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(task.id)
        end
      end

      context "is similar to a task id" do
        let!(:task) { Fabricate(:task) }

        before { Fabricate(:task) }

        it "returns matching search_results" do
          search_results = SearchResult.filter_by(query: "task #{task.id}")
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(task.id)
        end
      end
    end

    context "when :project_ids" do
      let(:project) { Fabricate(:project) }

      context "is nil" do
        let!(:issue) { Fabricate(:issue) }

        it "returns any project issue" do
          search_results = SearchResult.filter_by(project_ids: nil)
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(issue.id)
        end
      end

      context "contains a project id" do
        let!(:issue) { Fabricate(:issue, project: project) }

        before { Fabricate(:issue) }

        it "returns issues from the project only" do
          search_results = SearchResult.filter_by(project_ids: [project.id])
          expect(search_results.count).to eq(1)
          search_result = search_results.first
          expect(search_result.id).to eq(issue.id)
        end
      end
    end
  end

  describe ".split_id" do
    context "when given nil" do
      it "returns nil" do
        expect(SearchResult.split_id(nil)).to be_nil
      end
    end

    context "when given ''" do
      it "returns [nil, '']" do
        expect(SearchResult.split_id("")).to eq([nil, ""])
      end
    end

    context "when given ' '" do
      it "returns [nil, ' ']" do
        expect(SearchResult.split_id(" ")).to eq([nil, " "])
      end
    end

    context "when given '12'" do
      it "returns [12, '']" do
        expect(SearchResult.split_id("12")).to eq([12, ""])
      end
    end

    context "when given '12 alpha'" do
      it "returns [12, 'alpha']" do
        expect(SearchResult.split_id("12 alpha")).to eq([12, "alpha"])
      end
    end

    context "when given 'issue#12 alpha'" do
      it "returns [12, 'alpha']" do
        expect(SearchResult.split_id("issue#12 alpha")).to eq([12, "alpha"])
      end
    end

    context "when given 'issue-12 alpha'" do
      it "returns [12, 'alpha']" do
        expect(SearchResult.split_id("issue-12 alpha")).to eq([12, "alpha"])
      end
    end

    context "when given 'issue #12 alpha'" do
      it "returns [12, 'alpha']" do
        expect(SearchResult.split_id("issue #12 alpha")).to eq([12, "alpha"])
      end
    end

    context "when given 'Task#12 alpha'" do
      it "returns [12, 'alpha']" do
        expect(SearchResult.split_id("Task#12 alpha")).to eq([12, "alpha"])
      end
    end
  end

  describe ".all_visible" do
    let(:category) { Fabricate(:category) }
    let(:invisible_category) { Fabricate(:invisible_category) }
    let(:project) { Fabricate(:project, category: category) }
    let(:invisible_project) do
      Fabricate(:invisible_project, category: category)
    end
    let(:invisible_category_project) do
      Fabricate(:project, category: invisible_category)
    end

    before do
      Fabricate(:task, project: invisible_project)
      Fabricate(:task, project: invisible_category_project)
    end

    it "returns tasks from visible projects from visible categories" do
      task = Fabricate(:task, project: project)
      expect(SearchResult.all_visible.map(&:id)).to eq([task.id])
    end
  end

  describe ".with_notifications" do
    let(:worker) { Fabricate(:user_worker) }
    let(:first_issue) { Fabricate(:issue) }
    let(:first_task) { Fabricate(:task) }
    let(:second_issue) { Fabricate(:issue) }
    let(:second_task) { Fabricate(:task) }

    before do
      Timecop.freeze(2.weeks.ago) do
        Fabricate(:issue_notification, issue: first_issue)
      end
      Timecop.freeze(1.week.ago) do
        Fabricate(:task_notification, task: first_task)
      end

      Timecop.freeze(2.days.ago) do
        Fabricate(:issue_subscription, issue: second_issue, user: worker)
        Fabricate(:issue_notification, issue: second_issue, user: worker)
      end

      Fabricate(:task_subscription, task: second_task, user: worker)
      Fabricate(:task_notification, task: second_task, user: worker)
    end

    context "when order_by is not set" do
      it "returns all" do
        expect(
          SearchResult.order(created_at: :asc).map(&:id)
        ).to eq(
          [first_issue.id, first_task.id, second_issue.id, second_task.id]
        )
      end
    end

    context "when order_by is true" do
      it "returns all" do
        expect(
          SearchResult.with_notifications(worker, order_by: true)
              .order(created_at: :asc).map(&:id)
        ).to eq(
          [second_issue.id, second_task.id, first_issue.id, first_task.id]
        )
      end
    end
  end

  # INSTANCE

  describe "#issue?" do
    context "when class_name is 'Issue'" do
      before { subject.class_name = "Issue" }

      it "returns true" do
        expect(subject.issue?).to eq(true)
      end
    end

    context "when class_name is 'Task'" do
      before { subject.class_name = "Task" }

      it "returns false" do
        expect(subject.issue?).to eq(false)
      end
    end

    context "when class_name is something else" do
      before { subject.class_name = "Something Else" }

      it "returns false" do
        expect(subject.issue?).to eq(false)
      end
    end
  end

  describe "#task?" do
    context "when class_name is 'Issue'" do
      before { subject.class_name = "Issue" }

      it "returns false" do
        expect(subject.task?).to eq(false)
      end
    end

    context "when class_name is 'Task'" do
      before { subject.class_name = "Task" }

      it "returns true" do
        expect(subject.task?).to eq(true)
      end
    end

    context "when class_name is something else" do
      before { subject.class_name = "Something Else" }

      it "returns false" do
        expect(subject.task?).to eq(false)
      end
    end
  end

  describe "#heading" do
    let(:task) { Fabricate(:task) }

    before do
      subject.class_name = "Task"
      subject.id = task.id
      subject.summary = task.summary
    end

    context "when a summary" do
      it "returns class_name and short_summary" do
        expect(subject.heading)
          .to eq("Task \##{subject.id}: #{subject.summary}")
      end
    end

    context "when summary is blank" do
      before { subject.summary = "" }

      it "returns nil" do
        expect(subject.heading).to be_nil
      end
    end
  end

  describe "#short_summary" do
    let(:short_summary_length) { 70 }

    context "when summary is short" do
      before { subject.summary = "short" }

      it "lets it be" do
        expect(subject.short_summary).to eq("short")
      end
    end

    context "when summary is 1 too long" do
      before { subject.summary = "#{'a' * short_summary_length}b" }

      it "truncates it" do
        expect(subject.short_summary)
          .to eq("#{'a' * (short_summary_length - 3)}...")
      end
    end
  end

  describe "#status" do
    it "returns only nil for now" do
      expect(subject.status).to be_nil
    end
  end
end
