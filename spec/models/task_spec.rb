# frozen_string_literal: true

require "rails_helper"

RSpec.describe Task, type: :model do
  let(:worker) { Fabricate(:user_worker) }
  let(:project) { Fabricate(:project) }
  let(:task_type) { Fabricate(:task_type) }

  before do
    @task = Task.new(summary: "Summary", description: "Description",
                     user_id: worker.id, project_id: project.id,
                     task_type_id: task_type.id)
  end

  subject { @task }

  it { is_expected.to respond_to(:summary) }
  it { is_expected.to respond_to(:description) }
  it { is_expected.to respond_to(:closed) }
  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:task_type_id) }
  it { is_expected.to respond_to(:project_id) }
  it { is_expected.to respond_to(:category) }

  it { is_expected.to be_valid }

  it { is_expected.to validate_presence_of(:summary) }
  it { is_expected.to validate_length_of(:summary).is_at_most(200) }
  it { is_expected.to validate_presence_of(:description) }
  it { is_expected.to validate_length_of(:description).is_at_most(2000) }
  it { is_expected.to validate_presence_of(:user_id) }
  it { is_expected.to validate_presence_of(:task_type_id) }
  it { is_expected.to validate_presence_of(:project_id) }
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:task_type) }
  it { is_expected.to belong_to(:project) }
  it { is_expected.to belong_to(:issue) }
  it { is_expected.to have_many(:task_assignees) }
  it { is_expected.to have_many(:assignees) }
  it { is_expected.to have_many(:comments).dependent(:destroy) }
  it { is_expected.to have_many(:progressions) }
  it { is_expected.to have_many(:reviews) }

  # CLASS

  describe ".all_open" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_open).to eq([])
      end
    end

    context "when one open, one closed tasks" do
      let!(:task) { Fabricate(:open_task) }

      before do
        Fabricate(:closed_task)
      end

      it "returns the open one" do
        expect(Task.all_open).to eq([task])
      end
    end
  end

  describe ".all_closed" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_closed).to eq([])
      end
    end

    context "when one closed, one closed tasks" do
      let!(:task) { Fabricate(:closed_task) }

      before do
        Fabricate(:open_task)
      end

      it "returns the closed one" do
        expect(Task.all_closed).to eq([task])
      end
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
            expect(Task.filter(category: category)).to eq([])
          end
        end

        context "when the category has a task" do
          let!(:task) { Fabricate(:task, project: project) }

          before { Fabricate(:task) }

          it "returns it" do
            expect(Task.filter(category: category)).to eq([task])
          end
        end

        context "when the category has open and closed tasks" do
          let!(:open_task) { Fabricate(:open_task, project: project) }
          let!(:closed_task) { Fabricate(:closed_task, project: project) }

          before do
            Timecop.freeze(2.weeks.ago) do
              open_task.touch
            end
            Timecop.freeze(1.week.ago) do
              closed_task.touch
            end
          end

          it "orders by updated_at desc" do
            expect(Task.filter(category: category))
              .to eq([closed_task, open_task])
          end
        end

        context "and :open" do
          context "is set as 'open'" do
            let!(:task) { Fabricate(:open_task, project: project) }

            before do
              Fabricate(:open_task)
              Fabricate(:closed_task, project: project)
            end

            it "returns non-closed tasks" do
              expect(Task.filter(category: category, status: "open"))
                .to eq([task])
            end
          end

          context "is set as 'closed'" do
            let!(:task) { Fabricate(:closed_task, project: project) }

            before do
              Fabricate(:closed_task)
              Fabricate(:open_task, project: project)
            end

            it "returns non-closed tasks" do
              expect(Task.filter(category: category, status: "closed"))
                .to eq([task])
            end
          end

          context "is set as 'all'" do
            let!(:open_task) { Fabricate(:open_task, project: project) }
            let!(:closed_task) { Fabricate(:closed_task, project: project) }

            before do
              Fabricate(:task)
            end

            it "returns open and closed tasks" do
              tasks = Task.filter(category: category, status: "all")
              expect(tasks).to contain_exactly(open_task, closed_task)
            end
          end
        end

        context "and :reviewer" do
          let(:user) { Fabricate(:user_reviewer) }

          context "is set as user id with a task" do
            let!(:task) do
              Fabricate(:open_task, project: project, user: user)
            end

            before do
              Fabricate(:open_task, project: project)
            end

            it "returns user tasks" do
              expect(Task.filter(category: category, reviewer: user.id.to_s))
                .to eq([task])
            end
          end

          context "is set as user id without a task" do
            let!(:task) do
              Fabricate(:open_task, project: project)
            end

            it "returns []" do
              expect(Task.filter(category: category, reviewer: user.id.to_s))
                .to eq([])
            end
          end

          context "is blank" do
            let!(:task) do
              Fabricate(:open_task, project: project)
            end

            it "returns all user tasks" do
              expect(Task.filter(category: category, reviewer: ""))
                .to eq([task])
            end
          end
        end

        context "and :assigned" do
          let(:user) { Fabricate(:user_worker) }
          let(:different_user) { Fabricate(:user_worker) }

          context "is assigned to a task" do
            let!(:task) do
              Fabricate(:open_task, project: project, assignees: [user])
            end

            before do
              Fabricate(:open_task, project: project)
            end

            it "returns user tasks" do
              expect(Task.filter(category: category, assigned: user.id.to_s))
                .to eq([task])
            end
          end

          context "is set as user id without a task" do
            let!(:task) do
              Fabricate(:open_task, project: project,
                                    assignees: [different_user])
            end

            it "returns []" do
              expect(Task.filter(category: category, assigned: user.id.to_s))
                .to eq([])
            end
          end

          context "is blank" do
            let!(:task) do
              Fabricate(:open_task, project: project,
                                    assignees: [different_user])
            end

            it "returns all user tasks" do
              expect(Task.filter(category: category, assigned: ""))
                .to eq([task])
            end
          end
        end

        context "and :order" do
          context "is unset" do
            it "orders by updated_at desc" do
              second_task = Fabricate(:task, project: project)
              first_task = Fabricate(:task, project: project)

              Timecop.freeze(1.day.ago) do
                second_task.touch
              end

              expect(Task.filter(category: category))
                .to eq([first_task, second_task])
            end
          end

          context "is set as 'updated,desc'" do
            it "orders by updated_at desc" do
              second_task = Fabricate(:task, project: project)
              first_task = Fabricate(:task, project: project)

              Timecop.freeze(1.day.ago) do
                second_task.touch
              end

              options = { category: category, order: "updated,desc" }
              expect(Task.filter(options)).to eq([first_task, second_task])
            end
          end

          context "is set as 'updated,asc'" do
            it "orders by updated_at asc" do
              second_task = Fabricate(:task, project: project)
              first_task = Fabricate(:task, project: project)

              Timecop.freeze(1.day.ago) do
                first_task.touch
              end

              options = { category: category, order: "updated,asc" }
              expect(Task.filter(options)).to eq([first_task, second_task])
            end
          end

          context "is set as 'created,desc'" do
            it "orders by created_at desc" do
              first_task = nil
              second_task = nil

              Timecop.freeze(1.day.ago) do
                second_task = Fabricate(:task, project: project)
              end

              Timecop.freeze(1.hour.ago) do
                first_task = Fabricate(:task, project: project)
              end

              options = { category: category, order: "created,desc" }
              expect(Task.filter(options)).to eq([first_task, second_task])
            end
          end

          context "is set as 'created,asc'" do
            it "orders by created_at asc" do
              first_task = nil
              second_task = nil

              Timecop.freeze(1.hour.ago) do
                second_task = Fabricate(:task, project: project)
              end

              Timecop.freeze(1.day.ago) do
                first_task = Fabricate(:task, project: project)
              end

              options = { category: category, order: "created,asc" }
              expect(Task.filter(options)).to eq([first_task, second_task])
            end
          end

          context "is set as 'notupdated,desc'" do
            it "orders by updated_at desc" do
              second_task = Fabricate(:task, project: project)
              first_task = Fabricate(:task, project: project)

              Timecop.freeze(1.day.ago) do
                second_task.touch
              end

              options = { category: category, order: "notupdated,desc" }
              expect(Task.filter(options)).to eq([first_task, second_task])
            end
          end

          context "is set as 'updated,notdesc'" do
            it "orders by updated_at desc" do
              second_task = Fabricate(:task, project: project)
              first_task = Fabricate(:task, project: project)

              Timecop.freeze(1.day.ago) do
                second_task.touch
              end

              options = { category: category, order: "updated,notdesc" }
              expect(Task.filter(options)).to eq([first_task, second_task])
            end
          end
        end
      end

      context ":project" do
        context "when no tasks" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:different_project) { Fabricate(:project, category: category) }

          before { Fabricate(:task, project: different_project) }

          it "returns []" do
            expect(Task.filter(project: project)).to eq([])
          end
        end

        context "when the project has a task" do
          let(:category) { Fabricate(:category) }
          let(:project) { Fabricate(:project, category: category) }
          let(:different_project) { Fabricate(:project, category: category) }
          let!(:task) { Fabricate(:task, project: project) }

          before { Fabricate(:task, project: different_project) }

          it "returns it" do
            expect(Task.filter(project: project)).to eq([task])
          end
        end
      end
    end

    context "when no filters" do
      it "returns []" do
        Fabricate(:task)
        expect(Task.filter).to eq([])
      end
    end
  end

  # INSTANCE

  describe "#task_assignees" do
    let(:task) { Fabricate(:task) }

    context "when destroying task" do
      before { Fabricate(:task_assignee, task: task) }

      it "destroys it's task_assignees" do
        expect do
          task.destroy
        end.to change(TaskAssignee, :count).by(-1)
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

  describe "#status" do
    context "when closed is true" do
      context "and no assignees, progressions, and reviews" do
        let(:task) { Fabricate(:task) }

        it "returns 'unassigned'" do
          expect(task.status).to eq("unassigned")
        end
      end

      context "and a user is assigned" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before { task.assignees << user }

        it "returns 'assigned'" do
          expect(task.status).to eq("assigned")
        end
      end

      context "and has an unfinished progression" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:unfinished_progression, task: task)
        end

        it "returns 'in progress'" do
          expect(task.status).to eq("in progress")
        end
      end

      context "and has a finished progression" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
        end

        it "falls back to 'assigned'" do
          expect(task.status).to eq("assigned")
        end
      end

      context "and has a pending review" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
          Fabricate(:pending_review, task: task)
        end

        it "returns 'in review'" do
          expect(task.status).to eq("in review")
        end
      end

      context "and has a disapproved review" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
          Fabricate(:disapproved_review, task: task)
        end

        it "falls back to 'assigned'" do
          expect(task.status).to eq("assigned")
        end
      end
    end
  end

  describe "#assignable" do
    let(:task) { Fabricate(:task) }

    before { Fabricate(:user_worker) }

    it "returns User.assignable_employees" do
      expect(task.assignable).to eq(User.assignable_employees)
    end
  end

  describe "#reviewable" do
    let(:task) { Fabricate(:task) }

    before { Fabricate(:user_worker) }

    it "returns User.reviewers" do
      expect(task.reviewable).to eq(User.reviewers)
    end
  end

  describe "#heading" do
    let(:task) { Fabricate(:task, summary: "Foo") }

    context "when a summary" do
      it "returns 'Task: ' and short_summary" do
        expect(task.heading).to eq("Task: #{task.summary}")
      end
    end

    context "when summary is blank" do
      before { task.summary = "" }

      it "returns nil" do
        expect(task.heading).to be_nil
      end
    end
  end

  describe "#assigned" do
    let(:task) { Fabricate(:task) }

    context "and no progressions" do
      it "returns none" do
        expect(task.assigned).to eq([])
      end
    end

    context "and a progression" do
      let(:user) { Fabricate(:user_worker) }

      before { Fabricate(:progression, task: task, user: user) }

      it "returns progression users" do
        expect(task.assigned).to eq([user])
      end
    end

    context "and a progression is also an assignee" do
      let(:user) { Fabricate(:user_worker) }

      before do
        task.assignees << user
        Fabricate(:progression, task: task, user: user)
      end

      it "returns none" do
        expect(task.assigned).to eq([])
      end
    end
  end

  describe "#user_form_options" do
    let(:task) { Fabricate(:task) }

    context "when no users" do
      it "returns [['Admin', []], 'Reviewer', []]]" do
        expect(task.user_form_options).to eq([["Admin", []], ["Reviewer", []]])
      end
    end

    context "when users" do
      it "returns admins and reviewers" do
        admin = Fabricate(:user_admin)
        reviewer = Fabricate(:user_reviewer)
        Fabricate(:user_worker)
        Fabricate(:user_reporter)
        options = [
          ["Admin", [[admin.name_and_email, admin.id]]],
          ["Reviewer", [[reviewer.name_and_email, reviewer.id]]]
        ]
        expect(task.user_form_options).to eq(options)
      end
    end
  end
end
