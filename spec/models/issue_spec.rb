# frozen_string_literal: true

require "rails_helper"

RSpec.describe Issue, type: :model do
  let(:reporter) { Fabricate(:user_reporter) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue_type) { Fabricate(:issue_type) }

  before do
    @issue = Issue.new(summary: "Summary", description: "Description",
                       user_id: reporter.id, project_id: project.id,
                       issue_type_id: issue_type.id)
  end

  subject { @issue }

  it { is_expected.to be_valid }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:closed) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:issue_type_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:opened_at) }
  it { is_expected.to respond_to(:category) }
  it { is_expected.to respond_to(:tasks_count) }
  it { is_expected.to respond_to(:open_tasks_count) }
  it { is_expected.to respond_to(:github_id) }
  it { is_expected.to respond_to(:github_url) }
  it { is_expected.to respond_to(:status) }

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_length_of(:description).is_at_most(2000) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:issue_type_id) }
  it { is_expected.to validate_presence_of(:project_id) }

  describe "#status" do
    context "when a valid value" do
      %w[open being_worked_on addressed resolved duplicate
         closed].each do |value|
        before { subject.status = value }

        it { is_expected.to be_valid }
      end
    end

    context "when an invalid value" do
      ["notopen", nil, "", "being worked on"].each do |value|
        before { subject.status = value }

        it { is_expected.not_to be_valid }
      end
    end
  end

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:issue_type) }
  it { is_expected.to belong_to(:project) }

  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }
  it { is_expected.to have_many(:resolutions) }
  it { is_expected.to have_many(:issue_subscriptions).dependent(:destroy) }
  it { is_expected.to have_many(:subscribers) }
  it { is_expected.to have_many(:closures) }
  it { is_expected.to have_many(:reopenings) }

  it { is_expected.to have_one(:source_connection).dependent(:destroy) }
  it { is_expected.to have_many(:target_connections).dependent(:destroy) }
  it { is_expected.to have_many(:duplicates) }
  it { is_expected.to have_one(:duplicatee) }

  # CLASS

  describe ".all_non_closed" do
    let!(:issue) { Fabricate(:open_issue) }

    before do
      Fabricate(:closed_issue)
    end

    it "returns non-closed issues" do
      expect(Issue.all_non_closed).to eq([issue])
    end
  end

  describe ".all_open" do
    let!(:issue) { Fabricate(:open_issue) }

    before do
      Fabricate(:closed_issue)
      Fabricate(:being_worked_on_issue)
      Fabricate(:closed_issue, status: "open")
    end

    it "returns non-closed issues without a task" do
      expect(Issue.all_open).to eq([issue])
    end
  end

  describe ".all_closed" do
    context "when no issues" do
      before { Issue.destroy_all }

      it "returns []" do
        expect(Issue.all_closed).to eq([])
      end
    end

    context "when one closed, one closed issues" do
      let!(:issue) { Fabricate(:closed_issue) }

      before do
        Fabricate(:open_issue)
      end

      it "returns the closed one" do
        expect(Issue.all_closed).to eq([issue])
      end
    end
  end

  describe ".all_being_worked_on" do
    let(:issue) { Fabricate(:being_worked_on_issue) }

    before do
      Fabricate(:issue) # no tasks
      Fabricate(:addressed_issue)
      Fabricate(:being_worked_on_issue, closed: true)
    end

    it "returns open issues with an open task" do
      expect(Issue.all_being_worked_on).to eq([issue])
    end
  end

  describe ".all_addressed" do
    let(:issue) { Fabricate(:addressed_issue) }
    let(:pending_issue) { Fabricate(:addressed_issue) }
    let(:reopened_issue) { Fabricate(:addressed_issue) }

    before do
      Fabricate(:pending_resolution, issue: pending_issue)
      Timecop.freeze(1.day.ago) do
        Fabricate(:approved_resolution, issue: reopened_issue)
      end

      Fabricate(:issue)
      Fabricate(:resolved_issue)
      Fabricate(:being_worked_on_issue, closed: true)
    end

    it "returns closed/unresolved issues with no open tasks" do
      expect(Issue.all_addressed)
        .to match_array([issue, pending_issue, reopened_issue])
    end
  end

  describe ".all_resolved" do
    let(:issue) { Fabricate(:resolved_issue) }

    before do
      # Fabricate(:approved_resolution, issue: issue)
      Fabricate(:pending_resolution)
      Fabricate(:disapproved_resolution)

      reopened_issue = Fabricate(:closed_issue)
      Timecop.freeze(1.day.ago) do
        Fabricate(:approved_resolution, issue: reopened_issue)
      end

      open_issue = Fabricate(:open_issue)
      Fabricate(:approved_resolution, issue: open_issue)
    end

    it "returns issues with current approved resolutions" do
      expect(Issue.all_resolved).to eq([issue])
    end
  end

  describe ".filter_by" do
    context "when no issues" do
      it "returns []" do
        expect(Issue.filter_by(issue_status: "open")).to eq([])
      end
    end

    context "when :issue_status" do
      context "is set as 'open'" do
        let!(:issue) { Fabricate(:open_issue) }

        before do
          Fabricate(:closed_issue)
        end

        it "returns non-closed issues" do
          expect(Issue.filter_by(issue_status: "open")).to eq([issue])
        end
      end

      context "is set as 'closed'" do
        let!(:issue) { Fabricate(:closed_issue) }

        before do
          Fabricate(:open_issue)
        end

        it "returns non-closed issues" do
          expect(Issue.filter_by(issue_status: "closed")).to eq([issue])
        end
      end

      context "is set as 'being_worked_on'" do
        let(:issue) { Fabricate(:being_worked_on_issue) }

        before do
          Fabricate(:open_task, issue: issue)
          Fabricate(:open_issue)
        end

        it "returns issues with open tasks" do
          expect(Issue.filter_by(issue_status: "being_worked_on"))
            .to eq([issue])
        end
      end

      context "is set as 'addressed'" do
        let(:issue) { Fabricate(:addressed_issue) }

        before do
          Fabricate(:open_issue)
          Fabricate(:open_task, issue: Fabricate(:issue))
        end

        it "returns issues with approved tasks" do
          expect(Issue.filter_by(issue_status: "addressed")).to eq([issue])
        end
      end

      context "is set as 'resolved'" do
        let(:issue) { Fabricate(:resolved_issue) }

        before do
          Fabricate(:open_issue)
          Fabricate(:pending_resolution, issue: Fabricate(:issue))
        end

        it "returns issues with approved tasks" do
          expect(Issue.filter_by(issue_status: "resolved")).to eq([issue])
        end
      end

      context "is set as 'all'" do
        let!(:open_issue) { Fabricate(:open_issue) }
        let!(:closed_issue) { Fabricate(:closed_issue) }

        it "returns open and closed issues" do
          issues = Issue.filter_by(issue_status: "all")
          expect(issues).to contain_exactly(open_issue, closed_issue)
        end
      end
    end

    context "when :query" do
      context "is ''" do
        let!(:issue) { Fabricate(:issue) }

        it "returns all issues" do
          expect(Issue.filter_by(query: "")).to eq([issue])
        end
      end

      context "is 'beta'" do
        let!(:issue) { Fabricate(:issue, summary: "Beta Problem") }

        before { Fabricate(:issue) }

        it "returns matching issues" do
          expect(Issue.filter_by(query: "beta")).to eq([issue])
        end
      end
    end

    context "when :issue_type_id" do
      context "is blank" do
        let!(:issue) { Fabricate(:issue) }

        it "returns all issues" do
          expect(Issue.filter_by(issue_type_id: "")).to eq([issue])
        end
      end

      context "is not blank" do
        let(:issue_type) { Fabricate(:issue_type) }
        let!(:issue) { Fabricate(:issue, issue_type: issue_type) }

        before { Fabricate(:issue) }

        it "returns matching issues" do
          expect(Issue.filter_by(issue_type_id: issue_type.id)).to eq([issue])
        end
      end
    end

    context "when :issue_status and :query" do
      context "is 'open' and 'gamma'" do
        let!(:issue) { Fabricate(:open_issue, summary: "Gamma Good") }

        before do
          Fabricate(:closed_issue, summary: "Closed gamma")
          Fabricate(:open_issue)
        end

        it "returns matching issue" do
          expect(Issue.filter_by(issue_status: "open", query: "gamma"))
            .to eq([issue])
        end
      end
    end

    context "when :order" do
      context "is unset" do
        it "orders by updated_at desc" do
          second_issue = Fabricate(:issue)
          first_issue = Fabricate(:issue)

          Timecop.freeze(1.day.ago) do
            second_issue.touch
          end

          expect(Issue.filter_by(issue_status: "all"))
            .to eq([first_issue, second_issue])
        end
      end

      context "is set as 'updated,desc'" do
        it "orders by updated_at desc" do
          second_issue = Fabricate(:issue)
          first_issue = Fabricate(:issue)

          Timecop.freeze(1.day.ago) do
            second_issue.touch
          end

          options = { order: "updated,desc" }
          expect(Issue.filter_by(options)).to eq([first_issue, second_issue])
        end
      end

      context "is set as 'updated,asc'" do
        it "orders by updated_at asc" do
          second_issue = Fabricate(:issue)
          first_issue = Fabricate(:issue)

          Timecop.freeze(1.day.ago) do
            first_issue.touch
          end

          options = { order: "updated,asc" }
          expect(Issue.filter_by(options)).to eq([first_issue, second_issue])
        end
      end

      context "is set as 'created,desc'" do
        it "orders by created_at desc" do
          first_issue = nil
          second_issue = nil

          Timecop.freeze(1.day.ago) do
            second_issue = Fabricate(:issue)
          end

          Timecop.freeze(1.hour.ago) do
            first_issue = Fabricate(:issue)
          end

          options = { order: "created,desc" }
          expect(Issue.filter_by(options)).to eq([first_issue, second_issue])
        end
      end

      context "is set as 'created,asc'" do
        it "orders by created_at asc" do
          first_issue = nil
          second_issue = nil

          Timecop.freeze(1.hour.ago) do
            second_issue = Fabricate(:issue)
          end

          Timecop.freeze(1.day.ago) do
            first_issue = Fabricate(:issue)
          end

          options = { order: "created,asc" }
          expect(Issue.filter_by(options)).to eq([first_issue, second_issue])
        end
      end

      context "is set as 'notupdated,desc'" do
        it "orders by updated_at desc" do
          second_issue = Fabricate(:issue)
          first_issue = Fabricate(:issue)

          Timecop.freeze(1.day.ago) do
            second_issue.touch
          end

          options = { order: "notupdated,desc" }
          expect(Issue.filter_by(options)).to eq([first_issue, second_issue])
        end
      end

      context "is set as 'updated,notdesc'" do
        it "orders by updated_at desc" do
          second_issue = Fabricate(:issue)
          first_issue = Fabricate(:issue)

          Timecop.freeze(1.day.ago) do
            second_issue.touch
          end

          options = { order: "updated,notdesc" }
          expect(Issue.filter_by(options)).to eq([first_issue, second_issue])
        end
      end
    end

    context "when issue has 2 approved tasks" do
      let(:issue) { Fabricate(:addressed_issue) }

      before { Fabricate(:approved_task, issue: issue) }

      it "returns it once" do
        expect(Issue.filter_by(issue_status: "addressed")).to eq([issue])
      end
    end

    context "when no filters" do
      it "returns all issues" do
        issue = Fabricate(:issue)
        expect(Issue.filter_by).to eq([issue])
      end
    end

    context "when project scope" do
      let(:project) { Fabricate(:project) }

      before { Fabricate(:issue) }

      it "returns all project issues" do
        issue = Fabricate(:issue, project: project)
        expect(project.issues.filter_by(issue_status: "all")).to eq([issue])
      end
    end
  end

  describe ".filter_by_string" do
    context "when no issues" do
      it "returns []" do
        expect(Issue.filter_by_string("alpha")).to eq([])
      end
    end

    context "when issues" do
      context "and query is ''" do
        let!(:issue) { Fabricate(:issue) }

        it "returns all issues" do
          expect(Issue.filter_by_string("")).to eq([issue])
        end
      end

      context "and query matches an issue's summary" do
        let!(:issue) { Fabricate(:issue, summary: "Alpha Beta Gamma") }

        before do
          Fabricate(:issue, summary: "Beta Gamma")
        end

        it "returns one issue" do
          expect(Issue.filter_by_string("alpha")).to eq([issue])
        end
      end

      context "and query matches an issue's description" do
        let!(:issue) { Fabricate(:issue, description: "Alpha Beta Gamma") }

        before do
          Fabricate(:issue, description: "Beta Gamma")
        end

        it "returns one issue" do
          expect(Issue.filter_by_string("alpha")).to eq([issue])
        end
      end

      context "and query doesn't match an issue" do
        before do
          Fabricate(:issue, description: "Beta Gamma")
        end

        it "returns none" do
          expect(Issue.filter_by_string("alpha")).to eq([])
        end
      end

      context "and query matches one issue's summary, another's description" do
        let!(:first_issue) { Fabricate(:issue, summary: "Alpha Beta Gamma") }
        let!(:second_issue) do
          Fabricate(:issue, description: "Alpha Beta Gamma")
        end

        before do
          Fabricate(:issue, description: "Beta Gamma")
        end

        it "returns both issues" do
          expect(Issue.filter_by_string("alpha"))
            .to contain_exactly(first_issue, second_issue)
        end
      end
    end
  end

  describe ".filter_by_type" do
    let(:issue_type) { Fabricate(:issue_type) }

    context "when no issues" do
      it "returns []" do
        expect(Issue.filter_by_type(issue_type.id)).to eq([])
      end
    end

    context "when issues" do
      context "and type filter is blank" do
        let!(:issue) { Fabricate(:issue) }

        it "returns all" do
          expect(Issue.filter_by_type("")).to eq([issue])
        end
      end

      context "and type filter matches an issue" do
        let!(:issue) { Fabricate(:issue, issue_type: issue_type) }

        before { Fabricate(:issue) }

        it "returns match" do
          expect(Issue.filter_by_type(issue_type.id)).to eq([issue])
        end
      end

      context "and type filter doesn't match an issue" do
        before { Fabricate(:issue) }

        it "returns none" do
          expect(Issue.filter_by_type(issue_type.id)).to eq([])
        end
      end

      context "and type filter is invalid" do
        before { Fabricate(:issue) }

        it "returns none" do
          expect(Issue.filter_by_type("invalid")).to eq([])
        end
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
      Fabricate(:issue, project: invisible_project)
      Fabricate(:issue, project: invisible_category_project)
    end

    it "returns issues from visible projects from visible categories" do
      issue = Fabricate(:issue, project: project)
      expect(Issue.all_visible).to eq([issue])
    end
  end

  describe ".all_invisible" do
    let(:category) { Fabricate(:category) }
    let(:invisible_category) { Fabricate(:invisible_category) }
    let(:project) { Fabricate(:project, category: category) }
    let(:invisible_project) do
      Fabricate(:invisible_project, category: category)
    end
    let(:invisible_category_project) do
      Fabricate(:project, category: invisible_category)
    end

    before { Fabricate(:issue, project: project) }

    it "returns issues from visible projects from visible categories" do
      invisible_issue = Fabricate(:issue, project: invisible_project)
      invisible_category_issue =
        Fabricate(:issue, project: invisible_category_project)

      expect(Issue.all_invisible)
        .to contain_exactly(invisible_issue, invisible_category_issue)
    end
  end

  # INSTANCE

  describe "#tasks" do
    let(:issue) { Fabricate(:issue) }

    context "when destroying task" do
      it "nullifies tasks" do
        task = Fabricate(:task, issue: issue)

        expect do
          issue.destroy
          task.reload
        end.to change(task, :issue_id).to(nil)
      end
    end
  end

  describe "#description_html" do
    context "when description is _foo_" do
      before { subject.description = "_foo_" }

      it "adds em tags" do
        expect(subject.description_html).to eq("<p><em>foo</em></p>\n")
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

  describe "#id_and_summary" do
    context "when id is nil" do
      let(:issue) { Fabricate.build(:issue) }

      it "returns nil" do
        expect(issue.id_and_summary).to be_nil
      end
    end

    context "when summary nil" do
      let(:issue) { Fabricate(:issue) }

      before { issue.summary = nil }

      it "returns nil" do
        expect(issue.id_and_summary).to be_nil
      end
    end

    context "when id is not nil" do
      let(:issue) { Fabricate(:issue) }

      it "returns id and short_summary" do
        expect(issue.id_and_summary)
          .to eq("\##{issue.id} - #{issue.short_summary}")
      end
    end
  end

  describe "#open?" do
    context "closed is false" do
      before { subject.closed = false }

      it "returns true" do
        expect(subject.open?).to eq(true)
      end
    end

    context "closed is true" do
      before { subject.closed = true }

      it "returns false" do
        expect(subject.open?).to eq(false)
      end
    end
  end

  describe "#heading" do
    let(:issue) { Fabricate(:issue, summary: "Foo") }

    context "when a summary" do
      it "returns 'Issue: ' and short_summary" do
        expect(issue.heading).to eq("Issue \##{issue.id}: #{issue.summary}")
      end
    end

    context "when summary is blank" do
      before { issue.summary = "" }

      it "returns nil" do
        expect(issue.heading).to be_nil
      end
    end
  end

  describe "#set_opened_at" do
    context "after creating" do
      it "sets opened_at as created_at" do
        subject.save
        subject.reload
        expect(subject.opened_at).to eq(subject.created_at)
      end
    end

    context "after updating" do
      it "sets opened_at as created_at" do
        Timecop.freeze(1.week.ago) do
          subject.save
        end
        subject.update summary: "New summary"
        subject.reload
        expect(subject.opened_at).to eq(subject.created_at)
      end
    end
  end

  describe "#tasks_count" do
    let(:issue) { Fabricate(:issue) }

    context "when no tasks" do
      it "returns 0" do
        expect(issue.tasks_count).to eq(0)
      end
    end

    context "when open and closed tasks" do
      before do
        Fabricate(:open_task, issue: issue)
        Fabricate(:closed_task, issue: issue)
        issue.reload
      end

      it "returns 2" do
        expect(issue.tasks_count).to eq(2)
      end
    end
  end

  describe "#open_tasks?" do
    context "for a open issue" do
      context "and has an open task" do
        let(:issue) { Fabricate(:open_issue) }

        before { Fabricate(:open_task, issue: issue) }

        it "returns true" do
          expect(issue.send(:open_tasks?)).to eq(true)
        end
      end

      context "and has a closed task" do
        let(:issue) { Fabricate(:issue) }
        let(:task) { Fabricate(:closed_task, issue: issue) }

        it "returns false" do
          expect(issue.send(:open_tasks?)).to eq(false)
        end
      end
    end

    context "for a closed issue" do
      context "and has an open task" do
        let(:issue) { Fabricate(:closed_issue) }

        before { Fabricate(:open_task, issue: issue) }

        it "returns true" do
          expect(issue.send(:open_tasks?)).to eq(false)
        end
      end

      context "and has a closed task" do
        let(:issue) { Fabricate(:issue) }
        let(:task) { Fabricate(:closed_task, issue: issue) }

        before { Fabricate(:approved_review, task: task) }

        it "returns false" do
          expect(issue.send(:open_tasks?)).to eq(false)
        end
      end
    end
  end

  describe "#tasks_approved?" do
    let(:issue) { Fabricate(:closed_issue) }

    context "with no tasks" do
      it "returns false" do
        expect(issue.send(:tasks_approved?)).to eq(false)
      end
    end

    context "with closed & approved task" do
      before { Fabricate(:approved_task, issue: issue) }

      it "returns true" do
        expect(issue.send(:tasks_approved?)).to eq(true)
      end
    end

    context "with approved task and closed task" do
      before do
        Fabricate(:approved_task, issue: issue)
        Fabricate(:closed_task, issue: issue)
      end

      it "returns true" do
        expect(issue.send(:tasks_approved?)).to eq(true)
      end
    end

    context "with a closed unreviewed task" do
      before do
        Fabricate(:closed_task, issue: issue)
      end

      it "returns false" do
        expect(issue.send(:tasks_approved?)).to eq(false)
      end
    end

    context "with approved task and open task" do
      before do
        Fabricate(:approved_task, issue: issue)
        Fabricate(:open_task, issue: issue)
      end

      it "returns false" do
        expect(issue.send(:tasks_approved?)).to eq(false)
      end
    end

    context "when issue resolved" do
      before do
        Fabricate(:approved_task, issue: issue)
        allow(issue).to receive(:resolution_approved?) { true }
      end

      it "returns false" do
        expect(issue.send(:tasks_approved?)).to eq(false)
      end
    end

    context "when issue not closed" do
      before do
        Fabricate(:approved_task, issue: issue)
        issue.update_column :closed, false
      end

      it "returns false" do
        expect(issue.send(:tasks_approved?)).to eq(false)
      end
    end

    context "when approved task before opened_at" do
      before do
        Fabricate(:approved_task, issue: issue)
        issue.update_attribute :opened_at, (Time.now + 1.week)
      end

      it "returns true" do
        expect(issue.send(:tasks_approved?)).to eq(true)
      end
    end
  end

  describe "#resolution_approved?" do
    let(:issue) { Fabricate(:closed_issue) }

    context "with no resolutions" do
      it "returns false" do
        expect(issue.send(:resolution_approved?)).to eq(false)
      end
    end

    context "when one resolution" do
      context "is approved" do
        before do
          Fabricate(:approved_resolution, issue: issue)
        end

        it "returns true" do
          expect(issue.send(:resolution_approved?)).to eq(true)
        end
      end

      context "is disapproved" do
        before do
          Fabricate(:disapproved_resolution, issue: issue)
        end

        it "returns false" do
          expect(issue.send(:resolution_approved?)).to eq(false)
        end
      end

      context "is pending" do
        before do
          Fabricate(:pending_resolution, issue: issue)
        end

        it "returns false" do
          expect(issue.send(:resolution_approved?)).to eq(false)
        end
      end
    end

    context "when approved resolution is made invalid" do
      before do
        Timecop.freeze(1.day.ago) do
          Fabricate(:approved_resolution, issue: issue)
        end
        issue.reopen
      end

      it "returns false" do
        expect(issue.send(:resolution_approved?)).to eq(false)
      end
    end

    context "when disapproved resolution is made invalid" do
      before do
        Timecop.freeze(1.day.ago) do
          Fabricate(:disapproved_resolution, issue: issue)
        end
        issue.reopen
      end

      it "returns false" do
        expect(issue.send(:resolution_approved?)).to eq(false)
      end
    end

    context "when disapproved resolution is then approved" do
      before do
        Timecop.freeze(2.days.ago) do
          Fabricate(:disapproved_resolution, issue: issue)
        end
        Timecop.freeze(1.day.ago) do
          issue.reopen
        end
        Fabricate(:approved_resolution, issue: issue)
      end

      it "returns true" do
        expect(issue.send(:resolution_approved?)).to eq(true)
      end
    end
  end

  describe "#unresolved?" do
    context "for an open issue" do
      let(:issue) { Fabricate(:open_issue) }

      context "with no resolutions" do
        it "returns true" do
          expect(issue.unresolved?).to eq(true)
        end
      end

      context "with a pending resolution" do
        before { Fabricate(:pending_resolution, issue: issue) }

        it "returns false" do
          expect(issue.unresolved?).to eq(false)
        end
      end

      context "with a disapproved resolution" do
        before { Fabricate(:disapproved_resolution, issue: issue) }

        it "returns false" do
          expect(issue.unresolved?).to eq(false)
        end
      end

      context "with an approved resolution" do
        before { Fabricate(:approved_resolution, issue: issue) }

        it "returns false" do
          expect(issue.unresolved?).to eq(false)
        end
      end
    end

    context "for a closed issue" do
      let(:issue) { Fabricate(:closed_issue) }

      it "returns false" do
        expect(issue.unresolved?).to eq(false)
      end
    end
  end

  describe "#source_connection?" do
    let(:issue) { Fabricate(:issue) }

    context "when target_issue_connection" do
      before { Fabricate(:issue_connection, target: issue) }

      it "returns false" do
        expect(issue.send(:source_connection?)).to eq(false)
      end
    end

    context "when source_connection" do
      before { Fabricate(:issue_connection, source: issue) }

      it "returns true" do
        expect(issue.send(:source_connection?)).to eq(true)
      end
    end
  end

  describe "#update_status" do
    context "when closed is false" do
      context "and no tasks" do
        let(:issue) { Fabricate(:issue, status: "closed") }

        before do
          allow(issue).to receive(:open_tasks?) { false }
        end

        it "changes status to 'open'" do
          expect do
            issue.update_status
            issue.reload
          end.to change(issue, :status).to("open")
        end

        it "returns true" do
          expect(issue.update_status).to eq(true)
        end
      end

      context "and open_tasks? returns true" do
        let(:issue) { Fabricate(:issue) }

        before do
          allow(issue).to receive(:open_tasks?) { true }
        end

        it "changes status to 'being_worked_on'" do
          expect do
            issue.update_status
            issue.reload
          end.to change(issue, :status).to("being_worked_on")
        end

        it "returns true" do
          expect(issue.update_status).to eq(true)
        end
      end
    end

    context "when closed is true" do
      let(:issue) { Fabricate(:closed_issue) }

      before { issue.update_attribute :status, "almostclosed" }

      context "and without tasks" do
        before do
          allow(issue).to receive(:tasks_approved?) { false }
        end

        it "changes status to 'closed'" do
          expect do
            issue.update_status
            issue.reload
          end.to change(issue, :status).to("closed")
        end

        it "returns true" do
          expect(issue.update_status).to eq(true)
        end
      end

      context "and tasks_approved? returns true" do
        before do
          allow(issue).to receive(:tasks_approved?) { true }
          allow(issue).to receive(:resolution_approved?) { false }
        end

        it "changes status to 'addressed'" do
          expect do
            issue.update_status
            issue.reload
          end.to change(issue, :status).to("addressed")
        end

        it "returns true" do
          expect(issue.update_status).to eq(true)
        end
      end

      context "and resolved? returns true" do
        before do
          allow(issue).to receive(:tasks_approved?) { false }
          allow(issue).to receive(:resolution_approved?) { true }
        end

        it "changes status to 'resolved'" do
          expect do
            issue.update_status
            issue.reload
          end.to change(issue, :status).to("resolved")
        end

        it "returns true" do
          expect(issue.update_status).to eq(true)
        end
      end

      context "and tasks_approved?, resolved? return false" do
        before do
          allow(issue).to receive(:tasks_approved?) { false }
          allow(issue).to receive(:resolution_approved?) { false }
        end

        it "changes status to 'closed'" do
          expect do
            issue.update_status
            issue.reload
          end.to change(issue, :status).to("closed")
        end

        it "returns true" do
          expect(issue.update_status).to eq(true)
        end
      end

      context "and duplicate? returns true" do
        before do
          allow(issue).to receive(:source_connection?) { true }
        end

        it "changes status to 'duplicate'" do
          expect do
            issue.update_status
            issue.reload
          end.to change(issue, :status).to("duplicate")
        end

        it "returns true" do
          expect(issue.update_status).to eq(true)
        end
      end
    end
  end

  describe "#close" do
    context "when open" do
      let(:issue) { Fabricate(:open_issue) }

      it "changes closed to true" do
        expect do
          issue.close
          issue.reload
        end.to change(issue, :closed).to(true)
      end

      it "changes status to 'closed'" do
        expect do
          issue.close
          issue.reload
        end.to change(issue, :status).to("closed")
      end

      it "returns true" do
        expect(issue.close).to eq(true)
      end
    end

    context "when closed" do
      let(:issue) { Fabricate(:closed_issue) }

      it "doesn't change closed" do
        expect do
          issue.close
          issue.reload
        end.not_to change(issue, :closed)
      end

      it "doesn't change status" do
        expect do
          issue.close
          issue.reload
        end.not_to change(issue, :status)
      end

      it "returns true" do
        expect(issue.close).to eq(true)
      end
    end
  end

  describe "#reopen" do
    context "when closed" do
      let(:issue) { Fabricate(:closed_issue) }

      before do
        issue.update opened_at: 1.week.ago
      end

      it "changes closed to false" do
        expect do
          issue.reopen
          issue.reload
        end.to change(issue, :closed).to(false)
      end

      it "changes status to 'open'" do
        expect do
          issue.reopen
          issue.reload
        end.to change(issue, :status).to("open")
      end

      it "changes opened_at" do
        expect do
          issue.reopen
          issue.reload
        end.to change(issue, :opened_at)
      end

      it "returns true" do
        expect(issue.reopen).to eq(true)
      end
    end

    context "when open" do
      let(:issue) { Fabricate(:open_issue) }

      before do
        issue.update opened_at: 1.week.ago
      end

      it "doesn't change closed" do
        expect do
          issue.reopen
          issue.reload
        end.not_to change(issue, :closed)
      end

      it "doesn't change status" do
        expect do
          issue.reopen
          issue.reload
        end.not_to change(issue, :status)
      end

      it "changes opened_at" do
        expect do
          issue.reopen
          issue.reload
        end.to change(issue, :opened_at)
      end

      it "returns true" do
        expect(issue.reopen).to eq(true)
      end
    end
  end

  describe "#current_tasks" do
    let(:issue) { Fabricate(:issue) }

    context "when no tasks" do
      it "returns []" do
        expect(issue.current_tasks).to eq([])
      end
    end

    context "when tasks" do
      before do
        issue.update_columns created_at: 3.weeks.ago, opened_at: 1.week.ago
      end

      it "returns approved tasks created after opened_at" do
        task = Fabricate(:approved_task, issue: issue)
        Fabricate(:approved_task)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:approved_task, issue: issue)
        end

        expect(issue.current_tasks).to eq([task])
      end

      it "returns pending tasks created after opened_at" do
        task = Fabricate(:in_review_task, issue: issue)
        Fabricate(:in_review_task)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:in_review_task, issue: issue)
        end

        expect(issue.current_tasks).to eq([task])
      end

      it "returns disapproved tasks created after opened_at" do
        task = Fabricate(:disapproved_task, issue: issue)
        Fabricate(:approved_task)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:disapproved_task, issue: issue)
        end

        expect(issue.current_tasks).to eq([task])
      end
    end
  end

  describe "#current_resolutions" do
    let(:issue) { Fabricate(:issue) }

    context "when no resolutions" do
      it "returns []" do
        expect(issue.current_resolutions).to eq([])
      end
    end

    context "when resolutions" do
      before do
        issue.update_columns created_at: 3.weeks.ago, opened_at: 1.week.ago
      end

      it "returns approved resolutions created after opened_at" do
        resolution = Fabricate(:disapproved_resolution, issue: issue)
        Fabricate(:approved_resolution)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:approved_resolution, issue: issue)
        end
        resolution.update_column :approved, true

        expect(issue.current_resolutions).to eq([resolution])
      end

      it "returns pending resolutions created after opened_at" do
        resolution = Fabricate(:disapproved_resolution, issue: issue)
        Fabricate(:pending_resolution)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:pending_resolution, issue: issue)
        end
        resolution.update_column :approved, nil

        expect(issue.current_resolutions).to eq([resolution])
      end

      it "returns disapproved resolutions created after opened_at" do
        resolution = Fabricate(:disapproved_resolution, issue: issue)
        Fabricate(:approved_resolution)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:disapproved_resolution, issue: issue)
        end

        expect(issue.current_resolutions).to eq([resolution])
      end
    end
  end

  describe "#current_resolution" do
    let(:issue) { Fabricate(:issue) }

    context "when no resolutions" do
      it "returns nil" do
        expect(issue.current_resolution).to eq(nil)
      end
    end

    context "when resolutions" do
      it "returns last created resolution" do
        issue = nil
        Timecop.freeze(2.days.ago) do
          issue = Fabricate(:issue)
        end
        Timecop.freeze(1.day.ago) do
          Fabricate(:disapproved_resolution, issue: issue)
        end
        first_resolution = Fabricate(:disapproved_resolution, issue: issue)
        expect(issue.current_resolution).to eq(first_resolution)
      end

      it "doesn't return approved resolutions created before opened_at" do
        Timecop.freeze(5.hours.ago) do
          Fabricate(:approved_resolution, issue: issue)
        end
        Timecop.freeze(1.hour.ago) do
          issue.reopen
        end
        issue.reload
        expect(issue.current_resolution).to be_nil
      end
    end
  end

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:subscriber) { Fabricate(:user_reporter) }

    context "when not provided a subscriber" do
      context "but issue has a user" do
        let(:issue) { Fabricate(:issue, user: user) }

        context "that is not subscribed" do
          it "creates a issue_subscription for the issue user" do
            expect do
              issue.subscribe_user
            end.to change(user.issue_subscriptions, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before do
            Fabricate(:issue_subscription, issue: issue, user: user)
          end

          it "doesn't create a issue_subscription" do
            expect do
              issue.subscribe_user
            end.not_to change(IssueSubscription, :count)
          end
        end
      end

      context "and issue doesn't have a user" do
        let(:issue) { Fabricate.build(:issue, user: nil) }

        it "doesn't create a issue_subscription" do
          expect do
            issue.subscribe_user
          end.not_to change(IssueSubscription, :count)
        end
      end
    end

    context "when provided a subscriber" do
      let(:issue) { Fabricate(:issue, user: user) }

      context "that is not subscribed" do
        it "creates a issue_subscription for the subscriber" do
          expect do
            issue.subscribe_user(subscriber)
          end.to change(subscriber.issue_subscriptions, :count).by(1)
        end

        it "doesn't create a issue_subscription for the issue user" do
          expect do
            issue.subscribe_user(subscriber)
          end.to change(IssueSubscription, :count).by(1)
        end
      end
    end
  end

  describe "#subscribe_users" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:issue) { Fabricate(:issue, user: user, project: project) }

    it "runs subscribe_user" do
      expect(issue).to receive(:subscribe_user)
      issue.subscribe_users
    end

    context "when issue category has a subscriber" do
      let(:subscriber) { Fabricate(:user_reporter) }

      before do
        Fabricate(:category_issues_subscription, category: category,
                                                 user: subscriber)
      end

      it "creates a issue_subscription for the subscriber" do
        expect do
          issue.subscribe_users
        end.to change(subscriber.issue_subscriptions, :count).by(1)
      end

      it "creates 2 issue_subscriptions" do
        expect do
          issue.subscribe_users
        end.to change(IssueSubscription, :count).by(2)
      end
    end

    context "when issue project has a subscriber" do
      let(:subscriber) { Fabricate(:user_reporter) }

      before do
        Fabricate(:project_issues_subscription, project: project,
                                                user: subscriber)
      end

      it "creates a issue_subscription for the subscriber" do
        expect do
          issue.subscribe_users
        end.to change(subscriber.issue_subscriptions, :count).by(1)
      end

      it "creates 2 issue_subscriptions" do
        expect do
          issue.subscribe_users
        end.to change(IssueSubscription, :count).by(2)
      end
    end

    context "when issue category/project subscriber" do
      let(:subscriber) { Fabricate(:user_reporter) }

      before do
        Fabricate(:project_issues_subscription, project: project,
                                                user: subscriber)
        Fabricate(:category_issues_subscription, category: category,
                                                 user: subscriber)
      end

      it "creates a issue_subscription for the subscriber" do
        expect do
          issue.subscribe_users
        end.to change(subscriber.issue_subscriptions, :count).by(1)
      end

      it "creates 2 issue_subscriptions" do
        expect do
          issue.subscribe_users
        end.to change(IssueSubscription, :count).by(2)
      end
    end
  end

  describe "#approved_tasks" do
    let(:issue) { Fabricate(:issue) }

    context "when no tasks" do
      it "returns []" do
        expect(issue.approved_tasks).to eq([])
      end
    end

    context "when tasks" do
      it "returns all approved" do
        task = Fabricate(:approved_task, issue: issue)
        Fabricate(:in_review_task, issue: issue)

        expect(issue.approved_tasks).to eq([task])
      end
    end
  end

  describe "#addressed_at" do
    let(:issue) { Fabricate(:closed_issue) }

    context "when no tasks" do
      it "returns nil" do
        expect(issue.addressed_at).to be_nil
      end
    end

    context "when 1 open task" do
      before { Fabricate(:open_task, issue: issue) }

      it "returns nil" do
        expect(issue.addressed_at).to be_nil
      end
    end

    context "when a disapproved task" do
      before { Fabricate(:disapproved_task, issue: issue) }

      it "returns nil" do
        expect(issue.addressed_at).to be_nil
      end
    end

    context "when 1 approved task" do
      it "returns it's review date" do
        task = Fabricate(:closed_task, issue: issue)
        review = Fabricate(:approved_review, task: task)

        expect(issue.addressed_at).to eq(review.updated_at)
      end
    end

    context "when previously approved task" do
      before do
        task = nil
        Timecop.freeze(1.day.ago) do
          task = Fabricate(:approved_task, issue: issue)
        end
        Fabricate(:disapproved_review, task: task)
      end

      it "returns nil" do
        expect(issue.addressed_at).to be_nil
      end
    end

    context "when previously disapproved task" do
      it "returns it's approved review date" do
        task = nil
        Timecop.freeze(1.day.ago) do
          task = Fabricate(:disapproved_task, issue: issue)
        end
        review = Fabricate(:approved_review, task: task)

        expect(issue.addressed_at).to eq(review.updated_at)
      end
    end

    context "when approved and pending tasks" do
      it "returns approved's review date" do
        task = nil
        review = nil
        Timecop.freeze(2.days.ago) do
          task = Fabricate(:closed_task, issue: issue)
          Fabricate(:in_review_task, issue: issue)
        end
        Timecop.freeze(1.day.ago) do
          review = Fabricate(:approved_review, task: task)
        end
        Fabricate(:in_review_task, issue: issue)

        expect(issue.addressed_at).to eq(review.updated_at)
      end
    end

    context "when 2 approved tasks" do
      it "returns latest review date" do
        first_task = nil
        Timecop.freeze(2.days.ago) do
          first_task = Fabricate(:closed_task, issue: issue)
        end
        Timecop.freeze(1.day.ago) do
          Fabricate(:approved_review, task: first_task)
        end
        second_task = Fabricate(:closed_task, issue: issue)
        review = Fabricate(:approved_review, task: second_task)

        expect(issue.addressed_at).to eq(review.updated_at)
      end
    end
  end

  describe "#history_feed" do
    let(:issue) { Fabricate(:issue) }

    context "when no associations" do
      it "returns []" do
        expect(issue.history_feed).to eq([])
      end
    end

    context "when task" do
      it "returns [task]" do
        task = Fabricate(:task, issue: issue)
        Fabricate(:task)
        expect(issue.history_feed).to eq([task])
      end
    end

    context "when resolution" do
      it "returns [resolution]" do
        resolution = Fabricate(:resolution, issue: issue)
        Fabricate(:resolution)
        expect(issue.history_feed).to eq([resolution])
      end
    end

    context "when reopening" do
      it "returns [reopening]" do
        reopening = Fabricate(:issue_reopening, issue: issue)
        Fabricate(:issue_reopening)
        expect(issue.history_feed).to eq([reopening])
      end
    end

    context "when closure" do
      it "returns [closure]" do
        closure = Fabricate(:issue_closure, issue: issue)
        Fabricate(:issue_closure)
        expect(issue.history_feed).to eq([closure])
      end
    end

    context "when source_connection" do
      it "returns [source_connection]" do
        source_connection = Fabricate(:issue_connection, source: issue)
        Fabricate(:issue_connection)
        expect(issue.history_feed).to eq([source_connection])
      end
    end

    context "when closure and reopening" do
      it "orders by created_at" do
        reopening = Fabricate(:issue_reopening, issue: issue)
        second_closure = Fabricate(:issue_closure, issue: issue)
        first_closure = nil

        Timecop.freeze(1.day.ago) do
          first_closure = Fabricate(:issue_closure, issue: issue)
        end

        expect(issue.history_feed)
          .to eq([first_closure, reopening, second_closure])
      end
    end
  end
end
