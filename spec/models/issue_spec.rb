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

        context "when the category open and closed issues" do
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

        context "and :open" do
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
                .to eq(Issue.with_open_task)
            end
          end

          context "is set as '0'" do
            let!(:issue_without_task) do
              Fabricate(:open_issue, project: project, summary: "Without tasks")
            end
            let!(:issue_with_closed_task) do
              Fabricate(:open_issue, project: project,
                                     summary: "With closed tasks")
            end

            before do
              issue_with_open_task =
                Fabricate(:open_issue, project: project,
                                       summary: "With open tasks")
              Fabricate(:open_task, issue: issue_with_open_task)
              Fabricate(:closed_task, issue: issue_with_closed_task)
            end

            it "returns issues with no tasks or only closed tasks" do
              expect(Issue.filter(category: category, open_tasks: "0"))
                .to eq(Issue.without_open_task)
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

          context "is set as 'issues,updated,desc'" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              options = { category: category, order: "issues,updated,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'issues,updated,asc'" do
            it "orders by updated_at asc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                first_issue.touch
              end

              options = { category: category, order: "issues,updated,asc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'issues,created,desc'" do
            it "orders by created_at desc" do
              first_issue = nil
              second_issue = nil

              Timecop.freeze(1.day.ago) do
                second_issue = Fabricate(:issue, project: project)
              end

              Timecop.freeze(1.hour.ago) do
                first_issue = Fabricate(:issue, project: project)
              end

              options = { category: category, order: "issues,created,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'issues,created,asc'" do
            it "orders by created_at asc" do
              first_issue = nil
              second_issue = nil

              Timecop.freeze(1.hour.ago) do
                second_issue = Fabricate(:issue, project: project)
              end

              Timecop.freeze(1.day.ago) do
                first_issue = Fabricate(:issue, project: project)
              end

              options = { category: category, order: "issues,created,asc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'notissues,updated,desc'" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              options = { category: category, order: "notissues,updated,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'issues,notupdated,desc'" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              options = { category: category, order: "issues,notupdated,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'issues,updated,notdesc'" do
            it "orders by updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                second_issue.touch
              end

              options = { category: category, order: "issues,updated,notdesc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'tasks,created,asc'" do
            it "orders by oldest task created_at asc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                first_issue.touch
                Fabricate(:open_task, issue: first_issue)
              end

              Fabricate(:open_task, issue: second_issue)

              options = { category: category, order: "tasks,created,asc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'tasks,created,desc'" do
            it "orders by oldest task created_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)

              Timecop.freeze(1.day.ago) do
                first_issue.touch
                Fabricate(:open_task, issue: second_issue)
              end

              Fabricate(:open_task, issue: first_issue)

              options = { category: category, order: "tasks,created,desc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'tasks,updated,asc'" do
            it "orders by oldest task updated_at asc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)
              first_task = Fabricate(:open_task, issue: first_issue)

              Timecop.freeze(1.day.ago) do
                first_issue.touch
                first_task.touch
              end

              Fabricate(:open_task, issue: second_issue)

              options = { category: category, order: "tasks,updated,asc" }
              expect(Issue.filter(options)).to eq([first_issue, second_issue])
            end
          end

          context "is set as 'tasks,updated,desc'" do
            it "orders by oldest task updated_at desc" do
              second_issue = Fabricate(:issue, project: project)
              first_issue = Fabricate(:issue, project: project)
              second_task = Fabricate(:open_task, issue: second_issue)

              Timecop.freeze(1.day.ago) do
                first_issue.touch
                second_task.touch
              end

              Fabricate(:open_task, issue: first_issue)

              options = { category: category, order: "tasks,updated,desc" }
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
    let(:short_summary_length) { 100 }

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
end
