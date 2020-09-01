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

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_length_of(:description).is_at_most(2000) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:issue_type_id) }
  it { is_expected.to validate_presence_of(:project_id) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:issue_type) }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }
  it { is_expected.to have_many(:resolutions) }

  # CLASS

  describe ".all_open" do
    context "when no issues" do
      before { Issue.destroy_all }

      it "returns []" do
        expect(Issue.all_open).to eq([])
      end
    end

    context "when one open, one closed issues" do
      let!(:issue) { Fabricate(:open_issue) }

      before do
        Fabricate(:closed_issue)
      end

      it "returns the open one" do
        expect(Issue.all_open).to eq([issue])
      end
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

  describe ".with_open_task" do
    let(:issue) { Fabricate(:open_issue, project: project) }

    before do
      Fabricate(:open_task, issue: issue)
      Fabricate(:open_issue, project: project)

      issue_with_closed_task = Fabricate(:open_issue, project: project)
      Fabricate(:closed_task, issue: issue_with_closed_task)
    end

    it "returns issues with atleast 1 task" do
      expect(Issue.with_open_task).to eq([issue])
    end
  end

  describe ".without_open_task" do
    let!(:issue_without_task) do
      Fabricate(:open_issue, project: project, summary: "Without tasks")
    end
    let!(:issue_with_closed_task) do
      Fabricate(:open_issue, project: project, summary: "With closed tasks")
    end

    before do
      issue_with_open_task =
        Fabricate(:open_issue, project: project,
                               summary: "With open tasks")
      Fabricate(:open_task, issue: issue_with_open_task)
      Fabricate(:closed_task, issue: issue_with_closed_task)
    end

    it "returns issues with no tasks or only closed tasks" do
      expect(Issue.without_open_task)
        .to contain_exactly(issue_without_task, issue_with_closed_task)
    end
  end

  describe ".all_being_worked_on" do
    let(:issue) { Fabricate(:issue) }

    before do
      Fabricate(:task, issue: issue)

      Fabricate(:issue) # no tasks
      Fabricate(:closed_task, issue: Fabricate(:issue))
      Fabricate(:open_task, issue: Fabricate(:closed_issue))
    end

    it "returns open issues with an open task" do
      expect(Issue.all_being_worked_on).to eq([issue])
    end
  end

  describe ".all_addressed" do
    let(:issue) { Fabricate(:closed_issue) }
    let(:pending_issue) { Fabricate(:closed_issue) }
    let(:reopened_issue) { Fabricate(:closed_issue) }

    before do
      Fabricate(:approved_task, issue: issue)
      Fabricate(:approved_task, issue: pending_issue)
      Fabricate(:approved_task, issue: reopened_issue)
      Fabricate(:closed_task, issue: issue)

      Fabricate(:pending_resolution, issue: pending_issue)
      Timecop.freeze(1.day.ago) do
        Fabricate(:approved_resolution, issue: reopened_issue)
      end

      Fabricate(:approved_task, issue: Fabricate(:open_issue))
      Fabricate(:open_task, issue: Fabricate(:closed_issue))
      Fabricate(:closed_task, issue: Fabricate(:closed_issue))

      open_task_issue = Fabricate(:closed_issue)
      Fabricate(:approved_task, issue: open_task_issue)
      Fabricate(:open_task, issue: open_task_issue)

      resolved_issue = Fabricate(:closed_issue)
      Fabricate(:approved_task, issue: resolved_issue)
      Fabricate(:approved_resolution, issue: resolved_issue)
    end

    it "returns closed/unresolved issues with no open tasks" do
      expect(Issue.all_addressed)
        .to match_array([issue, pending_issue, reopened_issue])
    end
  end

  describe ".all_resolved" do
    let(:issue) { Fabricate(:closed_issue) }

    before do
      Fabricate(:approved_resolution, issue: issue)
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

  describe ".all_unresolved" do
    let!(:open_issue) { Fabricate(:open_issue) }
    let(:reopened_issue) { Fabricate(:open_issue) }
    let(:pending_issue) { Fabricate(:open_issue) }
    let(:disapproved_issue) { Fabricate(:open_issue) }
    let(:approved_issue) { Fabricate(:open_issue) }

    before do
      Fabricate(:approved_resolution, issue: approved_issue)
      Fabricate(:pending_resolution, issue: pending_issue)
      Fabricate(:disapproved_resolution, issue: disapproved_issue)

      Timecop.freeze(1.day.ago) do
        Fabricate(:approved_resolution, issue: reopened_issue)
      end
    end

    it "returns open issues without a  current approved resolution" do
      issues = [open_issue, reopened_issue, pending_issue, disapproved_issue]
      expect(Issue.all_unresolved).to match_array(issues)
    end
  end

  describe ".filter" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project, category: category) }
    let(:different_project) { Fabricate(:project, category: category) }

    context "when filters" do
      context ":category" do
        context "when no issues" do
          it "returns []" do
            expect(Issue.filter(category: category)).to eq([])
          end
        end

        context "when the category has an issue" do
          let!(:issue) { Fabricate(:issue, project: project) }

          before { Fabricate(:issue) }

          it "returns it" do
            expect(Issue.filter(category: category)).to eq([issue])
          end
        end

        context "when the category has open and closed issues" do
          let!(:open_issue) { Fabricate(:open_issue, project: project) }
          let!(:closed_issue) { Fabricate(:closed_issue, project: project) }

          before do
            Timecop.freeze(2.weeks.ago) do
              open_issue.touch
            end
            Timecop.freeze(1.week.ago) do
              closed_issue.touch
            end
          end

          it "orders by updated_at desc" do
            expect(Issue.filter(category: category))
              .to eq([closed_issue, open_issue])
          end
        end

        context "and :status" do
          context "is set as 'open'" do
            let!(:issue) { Fabricate(:open_issue, project: project) }

            before do
              Fabricate(:open_issue)
              Fabricate(:closed_issue, project: project)
            end

            it "returns non-closed issues" do
              expect(Issue.filter(category: category, status: "open"))
                .to eq([issue])
            end
          end

          context "is set as 'closed'" do
            let!(:issue) { Fabricate(:closed_issue, project: project) }

            before do
              Fabricate(:closed_issue)
              Fabricate(:open_issue, project: project)
            end

            it "returns non-closed issues" do
              expect(Issue.filter(category: category, status: "closed"))
                .to eq([issue])
            end
          end

          context "is set as 'being_worked_on'" do
            let(:issue) { Fabricate(:open_issue, project: project) }

            before do
              Fabricate(:open_task, issue: issue)

              Fabricate(:closed_issue)
              Fabricate(:open_issue, project: project)
            end

            it "returns issues with open tasks" do
              expect(
                Issue.filter(category: category, status: "being_worked_on")
              ).to eq([issue])
            end
          end

          context "is set as 'addressed'" do
            let(:issue) { Fabricate(:closed_issue, project: project) }

            before do
              Fabricate(:approved_task, issue: issue)

              Fabricate(:closed_issue)
              Fabricate(:open_issue, project: project)
              Fabricate(:open_task, issue: Fabricate(:issue, project: project))
            end

            it "returns issues with approved tasks" do
              expect(
                Issue.filter(category: category, status: "addressed")
              ).to eq([issue])
            end
          end

          context "is set as 'resolved'" do
            let(:issue) { Fabricate(:closed_issue, project: project) }

            before do
              Fabricate(:approved_resolution, issue: issue)

              Fabricate(:closed_issue)
              Fabricate(:open_issue, project: project)
              Fabricate(:pending_resolution,
                        issue: Fabricate(:issue, project: project))
            end

            it "returns issues with approved tasks" do
              expect(
                Issue.filter(category: category, status: "resolved")
              ).to eq([issue])
            end
          end

          context "is set as 'all'" do
            let!(:open_issue) { Fabricate(:open_issue, project: project) }
            let!(:closed_issue) { Fabricate(:closed_issue, project: project) }

            before do
              Fabricate(:issue)
            end

            it "returns open and closed issues" do
              issues = Issue.filter(category: category, status: "all")
              expect(issues).to contain_exactly(open_issue, closed_issue)
            end
          end
        end

        context "and :reporter" do
          let(:user) { Fabricate(:user_reporter) }

          context "is set as user id with an issue" do
            let!(:issue) do
              Fabricate(:open_issue, project: project, user: user)
            end

            before do
              Fabricate(:open_issue, project: project)
            end

            it "returns user issues" do
              expect(Issue.filter(category: category, reporter: user.id))
                .to eq([issue])
            end
          end

          context "is set as user id without an issue" do
            let!(:issue) do
              Fabricate(:open_issue, project: project)
            end

            it "returns []" do
              expect(Issue.filter(category: category, reporter: user.id))
                .to eq([])
            end
          end

          context "is blank" do
            let!(:issue) do
              Fabricate(:open_issue, project: project)
            end

            it "returns all user issues" do
              expect(Issue.filter(category: category, reporter: ""))
                .to eq([issue])
            end
          end
        end

        context "and :open_tasks" do
          context "is set as '1'" do
            before do
              issue = Fabricate(:open_issue, project: project)
              Fabricate(:open_task, issue: issue)
              Fabricate(:open_issue, project: project)

              issue_with_closed_task = Fabricate(:open_issue, project: project)
              Fabricate(:closed_task, issue: issue_with_closed_task)
            end

            it "returns issues with atleast 1 task" do
              expect(Issue.filter(category: category, open_tasks: "1"))
                .to match_array(Issue.with_open_task)
            end
          end

          context "is set as '0'" do
            let!(:issue_without_task) do
              Fabricate(:open_issue, project: project, summary: "Without tasks")
            end
            let(:issue_with_closed_task) do
              Fabricate(:open_issue, project: project,
                                     summary: "With closed tasks")
            end
            let(:issue_with_open_task) do
              Fabricate(:open_issue, project: project,
                                     summary: "With open tasks")
            end

            before do
              Fabricate(:open_task, issue: issue_with_open_task)
              Fabricate(:closed_task, issue: issue_with_closed_task)
            end

            it "returns issues with no tasks or only closed tasks" do
              expect(Issue.filter(category: category, open_tasks: "0"))
                .to match_array(Issue.without_open_task)
            end
          end

          context "is blank" do
            before do
              issue_with_task =
                Fabricate(:open_issue, project: project, summary: "With task")
              _issue_without_task =
                Fabricate(:open_issue, project: project,
                                       summary: "Without tasks")
              issue_with_closed_task =
                Fabricate(:open_issue, project: project,
                                       summary: "With closed tasks")

              Fabricate(:open_task, issue: issue_with_task)
              Fabricate(:closed_task, issue: issue_with_closed_task)
            end

            it "returns all issues" do
              expect(Issue.filter(category: category))
                .to match_array(category.issues)
            end
          end
        end

        context "and :order" do
          context "is unset" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              expect(Issue.filter(category: category))
                .to eq([first_issue, second_issue])
            end
          end

          context "is set as 'updated,desc'" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              options = { category: category, order: "updated,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'updated,asc'" do
            it "orders by updated_at asc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                first_issue.touch
              end

              options = { category: category, order: "updated,asc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'created,desc'" do
            it "orders by created_at desc" do
              first_issue = nil
              second_issue = nil

              Timecop.freeze(1.day.ago) do
                second_issue = Fabricate(:issue, project: project)
              end

              Timecop.freeze(1.hour.ago) do
                first_issue = Fabricate(:issue, project: project)
              end

              options = { category: category, order: "created,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'created,asc'" do
            it "orders by created_at asc" do
              first_issue = nil
              second_issue = nil

              Timecop.freeze(1.hour.ago) do
                second_issue = Fabricate(:issue, project: project)
              end

              Timecop.freeze(1.day.ago) do
                first_issue = Fabricate(:issue, project: project)
              end

              options = { category: category, order: "created,asc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'notupdated,desc'" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              options = { category: category, order: "notupdated,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'updated,notdesc'" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              options = { category: category, order: "updated,notdesc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end
        end
      end

      context ":project" do
        context "when no issues" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:different_project) { Fabricate(:project, category: category) }

          before { Fabricate(:issue, project: different_project) }

          it "returns []" do
            expect(Issue.filter(project: project)).to eq([])
          end
        end

        context "when the project has an issue" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:different_project) { Fabricate(:project, category: category) }
          let!(:issue) { Fabricate(:issue, project: project) }

          before { Fabricate(:issue, project: different_project) }

          it "returns it" do
            expect(Issue.filter(project: project)).to eq([issue])
          end
        end
      end
    end

    context "when no filters" do
      it "returns []" do
        Fabricate(:issue)
        expect(Issue.filter).to eq([])
      end
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
        expect(issue.heading).to eq("Issue: #{issue.summary}")
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

  describe "#working_on?" do
    context "for a open issue" do
      context "and has an open task" do
        let(:issue) { Fabricate(:open_issue) }

        before { Fabricate(:open_task, issue: issue) }

        it "returns true" do
          expect(issue.working_on?).to eq(true)
        end
      end

      context "and has a closed task" do
        let(:issue) { Fabricate(:issue) }
        let(:task) { Fabricate(:closed_task, issue: issue) }

        it "returns false" do
          expect(issue.working_on?).to eq(false)
        end
      end
    end

    context "for a closed issue" do
      context "and has an open task" do
        let(:issue) { Fabricate(:closed_issue) }

        before { Fabricate(:open_task, issue: issue) }

        it "returns true" do
          expect(issue.working_on?).to eq(false)
        end
      end

      context "and has a closed task" do
        let(:issue) { Fabricate(:issue) }
        let(:task) { Fabricate(:closed_task, issue: issue) }

        before { Fabricate(:approved_review, task: task) }

        it "returns false" do
          expect(issue.working_on?).to eq(false)
        end
      end
    end
  end

  describe "#addressed?" do
    let(:issue) { Fabricate(:closed_issue) }

    context "with no tasks" do
      it "returns false" do
        expect(issue.addressed?).to eq(false)
      end
    end

    context "with closed & approved task" do
      before { Fabricate(:approved_task, issue: issue) }

      it "returns true" do
        expect(issue.addressed?).to eq(true)
      end
    end

    context "with approved task and closed task" do
      before do
        Fabricate(:approved_task, issue: issue)
        Fabricate(:closed_task, issue: issue)
      end

      it "returns true" do
        expect(issue.addressed?).to eq(true)
      end
    end

    context "with a closed unreviewed task" do
      before do
        Fabricate(:closed_task, issue: issue)
      end

      it "returns false" do
        expect(issue.addressed?).to eq(false)
      end
    end

    context "with approved task and open task" do
      before do
        Fabricate(:approved_task, issue: issue)
        Fabricate(:open_task, issue: issue)
      end

      it "returns false" do
        expect(issue.addressed?).to eq(false)
      end
    end

    context "when issue resolved" do
      before do
        Fabricate(:approved_task, issue: issue)
        allow(issue).to receive(:resolved?) { true }
      end

      it "returns false" do
        expect(issue.addressed?).to eq(false)
      end
    end

    context "when issue not closed" do
      before do
        Fabricate(:approved_task, issue: issue)
        issue.update_column :closed, false
      end

      it "returns false" do
        expect(issue.addressed?).to eq(false)
      end
    end

    context "when approved task before opened_at" do
      before do
        Fabricate(:approved_task, issue: issue)
        issue.update_attribute :opened_at, (Time.now + 1.week)
      end

      it "returns true" do
        expect(issue.addressed?).to eq(true)
      end
    end
  end

  describe "#resolved?" do
    let(:issue) { Fabricate(:closed_issue) }

    context "with no resolutions" do
      it "returns false" do
        expect(issue.resolved?).to eq(false)
      end
    end

    context "when one resolution" do
      context "is approved" do
        before do
          Fabricate(:approved_resolution, issue: issue)
        end

        it "returns true" do
          expect(issue.resolved?).to eq(true)
        end
      end

      context "is disapproved" do
        before do
          Fabricate(:disapproved_resolution, issue: issue)
        end

        it "returns false" do
          expect(issue.resolved?).to eq(false)
        end
      end

      context "is pending" do
        before do
          Fabricate(:pending_resolution, issue: issue)
        end

        it "returns false" do
          expect(issue.resolved?).to eq(false)
        end
      end
    end

    context "when approved resolution is made invalid" do
      before do
        Timecop.freeze(1.day.ago) do
          Fabricate(:approved_resolution, issue: issue)
        end
        issue.open
      end

      it "returns false" do
        expect(issue.resolved?).to eq(false)
      end
    end

    context "when disapproved resolution is made invalid" do
      before do
        Timecop.freeze(1.day.ago) do
          Fabricate(:disapproved_resolution, issue: issue)
        end
        issue.open
      end

      it "returns false" do
        expect(issue.resolved?).to eq(false)
      end
    end

    context "when disapproved resolution is then approved" do
      before do
        Timecop.freeze(2.days.ago) do
          Fabricate(:disapproved_resolution, issue: issue)
        end
        Timecop.freeze(1.day.ago) do
          issue.open
        end
        Fabricate(:approved_resolution, issue: issue)
      end

      it "returns true" do
        expect(issue.resolved?).to eq(true)
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

  describe "#status" do
    context "when closed is false" do
      context "and no tasks" do
        let(:issue) { Fabricate(:issue) }

        before do
          allow(issue).to receive(:working_on?) { false }
        end

        it "returns 'open'" do
          expect(issue.status).to eq("open")
        end
      end

      context "and working_on? returns true" do
        let(:issue) { Fabricate(:issue) }

        before do
          allow(issue).to receive(:working_on?) { true }
        end

        it "returns 'being worked on'" do
          expect(issue.status).to eq("being worked on")
        end
      end
    end

    context "when closed is true" do
      let(:issue) { Fabricate(:closed_issue) }

      context "and without tasks" do
        before do
          allow(issue).to receive(:addressed?) { false }
        end

        it "returns 'closed'" do
          expect(issue.status).to eq("closed")
        end
      end

      context "and addressed? returns true" do
        before do
          allow(issue).to receive(:addressed?) { true }
          allow(issue).to receive(:resolved?) { false }
        end

        it "returns 'addressed'" do
          expect(issue.status).to eq("addressed")
        end
      end

      context "and resolved? returns true" do
        before do
          allow(issue).to receive(:addressed?) { false }
          allow(issue).to receive(:resolved?) { true }
        end

        it "returns 'resolved'" do
          expect(issue.status).to eq("resolved")
        end
      end

      context "and addressed?, resolved? return false" do
        before do
          allow(issue).to receive(:addressed?) { false }
          allow(issue).to receive(:resolved?) { false }
        end

        it "returns 'closed'" do
          expect(issue.status).to eq("closed")
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
    end

    context "when closed" do
      let(:issue) { Fabricate(:closed_issue) }

      it "doesn't change issue" do
        expect do
          issue.close
          issue.reload
        end.not_to change(issue, :closed)
      end
    end
  end

  describe "#open" do
    context "when closed" do
      let(:issue) { Fabricate(:closed_issue) }

      before do
        issue.update opened_at: 1.week.ago
      end

      it "changes closed to false" do
        expect do
          issue.open
          issue.reload
        end.to change(issue, :closed).to(false)
      end

      it "changes opened_at" do
        expect do
          issue.open
          issue.reload
        end.to change(issue, :opened_at)
      end
    end

    context "when open" do
      let(:issue) { Fabricate(:open_issue) }

      before do
        issue.update opened_at: 1.week.ago
      end

      it "doesn't change issue" do
        expect do
          issue.open
          issue.reload
        end.not_to change(issue, :closed)
      end

      it "changes opened_at" do
        expect do
          issue.open
          issue.reload
        end.to change(issue, :opened_at)
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
        task = Fabricate(:pending_task, issue: issue)
        Fabricate(:pending_task)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:pending_task, issue: issue)
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
          issue.open
        end
        issue.reload
        expect(issue.current_resolution).to be_nil
      end
    end
  end
end
