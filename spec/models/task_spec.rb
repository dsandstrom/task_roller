# frozen_string_literal: true

require "rails_helper"

RSpec.describe Task, type: :model do
  let(:worker) { Fabricate(:user_worker) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
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
  it { is_expected.to respond_to(:opened_at) }
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
  it { is_expected.to have_one(:source_task_connection).dependent(:destroy) }
  it { is_expected.to have_many(:target_task_connections).dependent(:destroy) }
  it { is_expected.to have_many(:duplicates) }
  it { is_expected.to have_one(:duplicatee) }
  it { is_expected.to have_many(:task_subscriptions).dependent(:destroy) }
  it { is_expected.to have_many(:subscribers) }

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

  describe ".all_in_review" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_in_review).to eq([])
      end
    end

    context "when tasks" do
      let(:task) { Fabricate(:open_task) }

      before do
        Fabricate(:pending_review, task: task)
        reopened_task = nil

        Timecop.freeze(1.day.ago) do
          reopened_task = Fabricate(:task)
          Fabricate(:pending_review, task: reopened_task)
        end
        reopened_task.open

        Fabricate(:closed_task)
      end

      it "returns open tasks that have a current pending review" do
        expect(Task.all_in_review).to eq([task])
      end
    end
  end

  describe ".all_in_progress" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_in_progress).to eq([])
      end
    end

    context "when tasks" do
      let(:task) { Fabricate(:open_task) }

      before do
        Fabricate(:progression, task: task)
        Fabricate(:finished_progression,
                  task: Fabricate(:open_task))
        Fabricate(:closed_task)
      end

      it "returns open tasks that have an unfinished progression" do
        expect(Task.all_in_progress).to eq([task])
      end
    end
  end

  describe ".all_assigned" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_assigned).to eq([])
      end
    end

    context "when tasks" do
      let(:worker) { Fabricate(:user_worker) }
      let(:task) { Fabricate(:open_task) }

      before do
        task.assignees << worker

        # assigned include in progress?
        # _unassigned_task = Fabricate(:open_task)
        # in_progress_task = Fabricate(:open_task)
        # in_progress_task.assignees << worker
        # Fabricate(:progression, task: in_progress_task)

        # assigned include in review?
        # in_review_task = Fabricate(:open_task)
        # in_review_task.assignees << worker
        # Fabricate(:pending_review, task: in_review_task)

        Fabricate(:closed_task).assignees << worker
      end

      it "returns open assigned tasks" do
        expect(Task.all_assigned).to eq([task])
      end
    end
  end

  describe ".all_unassigned" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_unassigned).to eq([])
      end
    end

    context "when tasks" do
      let(:task) { Fabricate(:open_task) }

      before do
        assigned_task = Fabricate(:open_task)
        assigned_task.assignees << worker
        Fabricate(:closed_task)
      end

      it "returns unassigned" do
        expect(Task.all_unassigned).to eq([task])
      end
    end
  end

  describe ".all_approved" do
    context "when no tasks" do
      before { Task.destroy_all }

      it "returns []" do
        expect(Task.all_approved).to eq([])
      end
    end

    context "when tasks" do
      let!(:task) { Fabricate(:approved_task) }

      before do
        Fabricate(:open_task)
        Fabricate(:closed_task)
        reopened_task = nil
        Timecop.freeze(1.day.ago) do
          reopened_task = Fabricate(:approved_task)
        end
        reopened_task.open
      end

      it "returns closed tasks that have an approved current review" do
        expect(Task.all_approved).to eq([task])
      end
    end
  end

  describe ".filter_by" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project, category: category) }
    let(:different_project) { Fabricate(:project, category: category) }

    context "when no tasks" do
      it "returns []" do
        expect(Task.filter_by(status: "all")).to eq([])
      end
    end

    context "when :status" do
      let(:in_review_task) { Fabricate(:open_task, project: project) }
      let(:in_progress_task) { Fabricate(:open_task, project: project) }
      let(:assigned_task) { Fabricate(:open_task, project: project) }
      let(:approved_task) { Fabricate(:approved_task, project: project) }
      let(:finished_task) { Fabricate(:open_task, project: project) }
      let(:reopened_task) { Fabricate(:task, project: project) }

      before do
        _unassigned_task = Fabricate(:open_task, project: project)

        tasks = [assigned_task, in_review_task, in_progress_task,
                 approved_task, finished_task, reopened_task]
        tasks.each do |task|
          task.assignees << worker
        end
        Fabricate(:pending_review, task: in_review_task)
        Fabricate(:progression, task: in_progress_task)
        Fabricate(:finished_progression, task: finished_task)
        Fabricate(:pending_review, task: reopened_task)

        Timecop.freeze(Time.now + 2.days) do
          reopened_task.open
        end

        Fabricate(:closed_task, project: project).assignees << worker
      end

      context "is set as 'in_review'" do
        it "returns open tasks that have a current pending review" do
          results = Task.filter_by(status: "in_review")
          expect(results.count).to eq(1)
          expect(results).to match_array(Task.all_in_review)
        end
      end

      context "is set as 'in_progress'" do
        it "returns open tasks that have an unfinished progression" do
          results = Task.filter_by(status: "in_progress")
          expect(results.count).to eq(1)
          expect(results).to match_array(category.tasks.all_in_progress)
        end
      end

      context "is set as 'assigned'" do
        it "returns open assigned tasks" do
          results = Task.filter_by(status: "assigned")
          expect(results.count).to eq(5)
          expect(results).to match_array(category.tasks.all_assigned)
        end
      end

      context "is set as 'open'" do
        it "returns open, reopened, pending, in review, in progress" do
          results = Task.filter_by(status: "open")
          expect(results.count).to eq(6)
          expect(results).to match_array(category.tasks.all_open)
        end
      end

      context "is set as 'approved'" do
        it "returns closed tasks that have an approved current review" do
          results = Task.filter_by(status: "approved")
          expect(results.count).to eq(1)
          expect(results).to match_array(category.tasks.all_approved)
        end
      end

      context "is set as 'closed'" do
        it "returns approved/unapproved closed tasks" do
          results = Task.filter_by(status: "closed")
          expect(results.count).to eq(2)
          expect(results).to match_array(category.tasks.all_closed)
        end
      end

      context "is set as 'unassigned'" do
        it "returns unassigned tasks" do
          results = Task.filter_by(status: "unassigned")
          expect(results.count).to eq(1)
          expect(results).to match_array(category.tasks.all_unassigned)
        end
      end

      context "is set as 'all'" do
        it "returns all category tasks" do
          tasks = Task.filter_by(status: "all")
          expect(tasks.count).to eq(8)
          expect(tasks).to match_array(category.tasks)
        end
      end
    end

    context "when :assigned" do
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
          expect(Task.filter_by(assigned: user.id.to_s)).to eq([task])
        end
      end

      context "is set as user id without a task" do
        let!(:task) do
          Fabricate(:open_task, project: project,
                                assignees: [different_user])
        end

        it "returns []" do
          expect(Task.filter_by(assigned: user.id.to_s)).to eq([])
        end
      end

      context "is blank" do
        let!(:task) do
          Fabricate(:open_task, project: project, assignees: [different_user])
        end

        it "returns all user tasks" do
          expect(Task.filter_by(assigned: "")).to eq([task])
        end
      end
    end

    context "when :order" do
      context "is unset" do
        it "orders by updated_at desc" do
          second_task = Fabricate(:task, project: project)
          first_task = Fabricate(:task, project: project)

          Timecop.freeze(1.day.ago) do
            second_task.touch
          end

          expect(Task.filter_by(category: category))
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

          options = { order: "updated,desc" }
          expect(Task.filter_by(options)).to eq([first_task, second_task])
        end
      end

      context "is set as 'updated,asc'" do
        it "orders by updated_at asc" do
          second_task = Fabricate(:task, project: project)
          first_task = Fabricate(:task, project: project)

          Timecop.freeze(1.day.ago) do
            first_task.touch
          end

          options = { order: "updated,asc" }
          expect(Task.filter_by(options)).to eq([first_task, second_task])
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

          options = { order: "created,desc" }
          expect(Task.filter_by(options)).to eq([first_task, second_task])
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

          options = { order: "created,asc" }
          expect(Task.filter_by(options)).to eq([first_task, second_task])
        end
      end

      context "is set as 'notupdated,desc'" do
        it "orders by updated_at desc" do
          second_task = Fabricate(:task, project: project)
          first_task = Fabricate(:task, project: project)

          Timecop.freeze(1.day.ago) do
            second_task.touch
          end

          options = { order: "notupdated,desc" }
          expect(Task.filter_by(options)).to eq([first_task, second_task])
        end
      end

      context "is set as 'updated,notdesc'" do
        it "orders by updated_at desc" do
          second_task = Fabricate(:task, project: project)
          first_task = Fabricate(:task, project: project)

          Timecop.freeze(1.day.ago) do
            second_task.touch
          end

          options = { order: "updated,notdesc" }
          expect(Task.filter_by(options)).to eq([first_task, second_task])
        end
      end
    end

    context "when task has 2 assignees" do
      it "returns task once" do
        task = Fabricate(:task)

        2.times { Fabricate(:task_assignee, task: task) }

        expect(Task.filter_by(status: "assigned")).to eq([task])
      end
    end

    context "when no filters" do
      it "returns all" do
        task = Fabricate(:task)
        expect(Task.filter_by).to eq([task])
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
      let(:task) { Fabricate.build(:task) }

      it "returns nil" do
        expect(task.id_and_summary).to be_nil
      end
    end

    context "when summary nil" do
      let(:task) { Fabricate(:task) }

      before { task.summary = nil }

      it "returns nil" do
        expect(task.id_and_summary).to be_nil
      end
    end

    context "when id is not nil" do
      let(:task) { Fabricate(:task) }

      it "returns id and short_summary" do
        expect(task.id_and_summary)
          .to eq("\##{task.id} - #{task.short_summary}")
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

  describe "#concluded_reviews" do
    let(:task) { Fabricate(:task) }

    it "returns reviews with approved as true or false" do
      Fabricate(:approved_review)
      pending_review = Fabricate(:disapproved_review, task: task)
      disapproved_review = Fabricate(:disapproved_review, task: task)
      approved_review = Fabricate(:approved_review, task: task)
      pending_review.update_column :approved, nil

      expect(task.concluded_reviews)
        .to contain_exactly(approved_review, disapproved_review)
    end

    it "orders by updated_at asc" do
      first_review = nil
      second_review = nil

      Timecop.freeze(2.weeks.ago) do
        second_review = Fabricate(:disapproved_review, task: task)
      end
      Timecop.freeze(1.week.ago) do
        first_review = Fabricate(:approved_review, task: task)
      end
      second_review.touch

      expect(task.concluded_reviews).to eq([first_review, second_review])
    end
  end

  describe "#current_reviews" do
    let(:task) { Fabricate(:task) }

    context "when no reviews" do
      it "returns []" do
        expect(task.current_reviews).to eq([])
      end
    end

    context "when reviews" do
      before do
        Timecop.freeze(1.week.ago) do
          task.open
        end
      end

      it "returns approved reviews created after opened_at" do
        review = Fabricate(:disapproved_review, task: task)
        Fabricate(:approved_review)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:approved_review, task: task)
        end
        review.update_column :approved, true

        expect(task.current_reviews).to eq([review])
      end

      it "returns pending reviews created after opened_at" do
        review = Fabricate(:disapproved_review, task: task)
        Fabricate(:pending_review)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:pending_review, task: task)
        end
        review.update_column :approved, nil

        expect(task.current_reviews).to eq([review])
      end

      it "returns disapproved reviews created after opened_at" do
        review = Fabricate(:disapproved_review, task: task)
        Fabricate(:disapproved_review)
        Timecop.freeze(2.weeks.ago) do
          Fabricate(:disapproved_review, task: task)
        end

        expect(task.current_reviews).to eq([review])
      end
    end
  end

  describe "#in_review?" do
    context "when closed is false" do
      context "and has a pending review" do
        let(:task) { Fabricate(:open_task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
          Fabricate(:pending_review, task: task)
        end

        it "returns true" do
          expect(task.in_review?).to eq(true)
        end
      end

      context "and has an approved review" do
        let(:task) { Fabricate(:open_task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
          Fabricate(:approved_review, task: task)
        end

        it "returns false" do
          expect(task.in_review?).to eq(false)
        end
      end

      context "and has a disapproved review" do
        let(:task) { Fabricate(:open_task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
          Fabricate(:disapproved_review, task: task)
        end

        it "returns false" do
          expect(task.in_review?).to eq(false)
        end
      end

      context "and has a pending review before opened_at" do
        let(:task) { Fabricate(:open_task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
          Timecop.freeze(1.day.ago) do
            Fabricate(:pending_review, task: task)
          end
        end

        it "returns false" do
          expect(task.in_review?).to eq(false)
        end
      end
    end

    context "when closed is true" do
      context "and has a pending review" do
        let(:task) { Fabricate(:closed_task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
          Fabricate(:pending_review, task: task)
        end

        it "returns false" do
          expect(task.in_review?).to eq(false)
        end
      end
    end
  end

  describe "#in_progress?" do
    context "for a open task" do
      context "and has an unfinished progression" do
        let(:task) { Fabricate(:open_task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:unfinished_progression, task: task)
        end

        it "returns true" do
          expect(task.in_progress?).to eq(true)
        end
      end

      context "and has a finished progression" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:finished_progression, task: task)
        end

        it "returns false" do
          expect(task.in_progress?).to eq(false)
        end
      end

      context "and task has a pending review" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:unfinished_progression, task: task)
          Fabricate(:pending_review, task: task)
        end

        it "returns false" do
          expect(task.in_progress?).to eq(false)
        end
      end
    end

    context "for a closed task" do
      context "and has an unfinished progression" do
        let(:task) { Fabricate(:closed_task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:unfinished_progression, task: task)
        end

        it "returns false" do
          expect(task.in_progress?).to eq(false)
        end
      end
    end
  end

  describe "#assigned?" do
    context "for a open task" do
      context "and a user is not assigned" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        it "returns false" do
          expect(task.assigned?).to eq(false)
        end
      end

      context "and a user is assigned" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before { task.assignees << user }

        it "returns true" do
          expect(task.assigned?).to eq(true)
        end
      end

      context "and task has a pending review" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:pending_review, task: task)
        end

        it "returns false" do
          expect(task.assigned?).to eq(false)
        end
      end

      context "and task has a unfinished progression" do
        let(:task) { Fabricate(:task) }
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:unfinished_progression, task: task)
        end

        it "returns false" do
          expect(task.assigned?).to eq(false)
        end
      end
    end

    context "when closed is true" do
      context "and has a pending review" do
        let(:task) { Fabricate(:closed_task) }
        let(:user) { Fabricate(:user_worker) }

        before { task.assignees << user }

        it "returns false" do
          expect(task.assigned?).to eq(false)
        end
      end
    end
  end

  describe "#approved?" do
    let(:task) { Fabricate(:task) }

    context "when no reviews" do
      it "returns false" do
        expect(task.approved?).to eq(false)
      end
    end

    context "when approved review" do
      before { Fabricate(:approved_review, task: task) }

      it "returns true" do
        expect(task.approved?).to eq(true)
      end
    end

    context "when disapproved review" do
      before { Fabricate(:disapproved_review, task: task) }

      it "returns false" do
        expect(task.approved?).to eq(false)
      end
    end
  end

  describe "#status" do
    context "when closed is false" do
      context "and no assignees, progressions, and reviews" do
        let(:task) { Fabricate(:task) }

        before do
          allow(task).to receive(:in_review?) { false }
          allow(task).to receive(:in_progress?) { false }
          allow(task).to receive(:assigned?) { false }
        end

        it "returns 'open'" do
          expect(task.status).to eq("open")
        end
      end

      context "and in_review? returns true" do
        let(:task) { Fabricate(:task) }

        before do
          allow(task).to receive(:in_review?) { true }
          allow(task).to receive(:in_progress?) { true }
          allow(task).to receive(:assigned?) { true }
        end

        it "returns 'in review'" do
          expect(task.status).to eq("in review")
        end
      end

      context "and in_progress? returns true" do
        let(:task) { Fabricate(:task) }

        before do
          allow(task).to receive(:in_review?) { false }
          allow(task).to receive(:in_progress?) { true }
          allow(task).to receive(:assigned?) { true }
        end

        it "returns 'in progress'" do
          expect(task.status).to eq("in progress")
        end
      end

      context "and assigned? returns true" do
        let(:task) { Fabricate(:task) }

        before do
          allow(task).to receive(:in_review?) { false }
          allow(task).to receive(:in_progress?) { false }
          allow(task).to receive(:assigned?) { true }
        end

        it "returns 'assigned'" do
          expect(task.status).to eq("assigned")
        end
      end
    end

    context "when closed is true" do
      let(:task) { Fabricate(:closed_task) }

      context "and approved? returns false" do
        before do
          allow(task).to receive(:approved?) { false }
        end

        it "returns 'closed'" do
          expect(task.status).to eq("closed")
        end
      end

      context "and approved? returns true" do
        before do
          allow(task).to receive(:approved?) { true }
        end

        it "returns 'approved'" do
          expect(task.status).to eq("approved/closed")
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
        expect(task.heading).to eq("Task \##{task.id}: #{task.summary}")
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
    context "for an open task" do
      let(:task) { Fabricate(:open_task) }

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

      context "and a progression user is also an assignee" do
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:progression, task: task, user: user)
        end

        it "returns none" do
          expect(task.assigned).to eq([])
        end
      end

      context "and two progressions" do
        context "for the same user" do
          let(:user) { Fabricate(:user_worker) }

          before do
            Fabricate(:finished_progression, task: task, user: user)
            Fabricate(:progression, task: task, user: user)
          end

          it "returns user once" do
            expect(task.assigned).to eq([user])
          end
        end

        context "for the different users" do
          let(:first_user) { Fabricate(:user_worker) }
          let(:second_user) { Fabricate(:user_worker) }

          before do
            Timecop.freeze(1.day.ago) do
              Fabricate(:finished_progression, task: task, user: second_user)
            end

            Fabricate(:finished_progression, task: task, user: first_user)
          end

          it "orders by created_at" do
            expect(task.assigned).to eq([first_user, second_user])
          end
        end
      end
    end

    context "for a closed task" do
      let(:task) { Fabricate(:closed_task) }

      context "and a progression user is also an assignee" do
        let(:user) { Fabricate(:user_worker) }

        before do
          task.assignees << user
          Fabricate(:progression, task: task, user: user)
        end

        it "returns user" do
          expect(task.assigned).to eq([user])
        end
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

  describe "#current_review" do
    let(:task) { Fabricate(:task) }

    context "when no reviews" do
      it "returns nil" do
        expect(task.current_review).to eq(nil)
      end
    end

    context "when reviews" do
      before do
        Timecop.freeze(1.day.ago) do
          Fabricate(:approved_review, task: task)
        end
      end

      it "returns last created review" do
        first_review = Fabricate(:disapproved_review, task: task)
        expect(task.current_review).to eq(first_review)
      end

      it "doesn't return approved reviews created before opened_at" do
        Timecop.freeze(5.hours.ago) do
          Fabricate(:approved_review, task: task)
        end
        Timecop.freeze(1.hour.ago) do
          task.open
        end
        task.reload
        expect(task.current_review).to be_nil
      end
    end
  end

  describe "#close" do
    context "when open" do
      let(:task) { Fabricate(:open_task) }

      it "changes closed to true" do
        expect do
          task.close
          task.reload
        end.to change(task, :closed).to(true)
      end
    end

    context "when closed" do
      let(:task) { Fabricate(:closed_task) }

      it "doesn't change task" do
        expect do
          task.close
          task.reload
        end.not_to change(task, :closed)
      end
    end

    context "when an unfinished progression" do
      let(:task) { Fabricate(:open_task) }
      let!(:progression) { Fabricate(:unfinished_progression, task: task) }

      it "changes closed to true" do
        expect do
          task.close
          task.reload
        end.to change(task, :closed).to(true)
      end

      it "changes it's finished to true" do
        expect do
          task.close
          progression.reload
        end.to change(progression, :finished).to(true)
      end

      it "returns true" do
        expect(task.close).to eq(true)
      end
    end

    context "when a finished progression" do
      let(:task) { Fabricate(:open_task) }
      let!(:progression) { Fabricate(:finished_progression, task: task) }

      it "changes closed to true" do
        expect do
          task.close
          task.reload
        end.to change(task, :closed).to(true)
      end

      it "doesn't change it's finished" do
        expect do
          task.close
          progression.reload
        end.not_to change(progression, :finished)
      end

      it "returns true" do
        expect(task.close).to eq(true)
      end
    end

    context "when an unfinished and invalid progression" do
      let(:task) { Fabricate(:open_task) }
      let(:progression) { Fabricate(:unfinished_progression, task: task) }

      before do
        # make previous progression invalid
        invalid = Fabricate(:progression, task: task)
        invalid.update_columns finished: false, finished_at: nil
        progression.update_column :user_id, invalid.user_id
      end

      it "doesn't change it's closed" do
        expect do
          task.close
          task.reload
        end.not_to change(task, :closed).from(false)
      end

      it "doesn't change it's finished" do
        expect do
          task.close
          progression.reload
        end.not_to change(progression, :finished)
      end

      it "returns false" do
        expect(task.close).to eq(false)
      end
    end

    context "when an pending review" do
      let(:task) { Fabricate(:open_task) }
      let!(:review) { Fabricate(:pending_review, task: task) }

      it "changes closed to true" do
        expect do
          task.close
          task.reload
        end.to change(task, :closed).to(true)
      end

      it "changes the review's approved to false" do
        expect do
          task.close
          review.reload
        end.to change(review, :approved).to(false)
      end

      it "returns true" do
        expect(task.close).to eq(true)
      end
    end

    context "when an open issue" do
      let(:issue) { Fabricate(:open_issue) }
      let(:task) { Fabricate(:open_task, issue: issue) }

      context "that has no other tasks" do
        it "changes closed to true" do
          expect do
            task.close
            task.reload
          end.to change(task, :closed).to(true)
        end

        it "changes the issues's closed to true" do
          expect do
            task.close
            issue.reload
          end.to change(issue, :closed).to(true)
        end

        it "returns true" do
          expect(task.close).to eq(true)
        end
      end

      context "that has other open tasks" do
        before { Fabricate(:open_task, issue: issue) }

        it "changes closed to true" do
          expect do
            task.close
            task.reload
          end.to change(task, :closed).to(true)
        end

        it "doesn't change the issues's closed" do
          expect do
            task.close
            issue.reload
          end.not_to change(issue, :closed)
        end

        it "returns true" do
          expect(task.close).to eq(true)
        end
      end

      context "that has other closed tasks" do
        before { Fabricate(:closed_task, issue: issue) }

        it "changes closed to true" do
          expect do
            task.close
            task.reload
          end.to change(task, :closed).to(true)
        end

        it "changes the issues's closed to true" do
          expect do
            task.close
            issue.reload
          end.to change(issue, :closed).to(true)
        end

        it "returns true" do
          expect(task.close).to eq(true)
        end
      end
    end
  end

  describe "#open" do
    context "when closed" do
      let(:task) { Fabricate(:closed_task) }

      before do
        task.update opened_at: 1.week.ago
      end

      it "changes closed to false" do
        expect do
          task.open
          task.reload
        end.to change(task, :closed).to(false)
      end

      it "changes opened_at" do
        expect do
          task.open
          task.reload
        end.to change(task, :opened_at)
      end

      context "with a closed issue" do
        let(:issue) { Fabricate(:closed_issue) }

        before { task.update issue: issue }

        it "runs open on the issue" do
          expect(issue).to receive(:open)
          task.open
        end
      end

      context "with an open issue" do
        let(:issue) { Fabricate(:open_issue) }

        before do
          task.update issue: issue
          Fabricate(:open_task, issue: issue)
        end

        it "doesn't run open on the issue" do
          expect(issue).not_to receive(:open)
          task.open
        end
      end
    end

    context "when open" do
      let(:task) { Fabricate(:open_task) }

      before do
        task.update opened_at: 1.week.ago
      end

      it "doesn't change task" do
        expect do
          task.open
          task.reload
        end.not_to change(task, :closed)
      end

      it "changes opened_at" do
        expect do
          task.open
          task.reload
        end.to change(task, :opened_at)
      end
    end
  end

  describe "#finish" do
    context "when an unfinished progression" do
      let(:task) { Fabricate(:open_task) }

      it "changes it's finished to true" do
        progression = Fabricate(:unfinished_progression, task: task)

        expect do
          task.finish
          progression.reload
        end.to change(progression, :finished).to(true)
      end

      it "returns true" do
        expect(task.finish).to eq(true)
      end
    end

    context "when no unfinished progressions" do
      let(:task) { Fabricate(:open_task) }

      it "doesn't raise an error" do
        expect do
          task.finish
        end.not_to raise_error
      end

      it "returns true" do
        expect(task.finish).to eq(true)
      end
    end
  end

  describe "#finish_progressions" do
    let(:task) { Fabricate(:open_task) }
    let(:user) { Fabricate(:user_worker) }

    before { task.assignees << user }

    context "when a user is unassigned" do
      it "runs user.finish_progressions" do
        Fabricate(:unfinished_progression, task: task, user: user)
        expect(user).to receive(:finish_progressions)
        task.update(assignee_ids: [])
      end
    end

    context "when a user is not unassigned" do
      it "doesn't change it's progressions" do
        Fabricate(:unfinished_progression, task: task, user: user)
        allow(task).to receive(:assignees) { [user] }
        expect(user).not_to receive(:finish_progressions)
        task.update(assignee_ids: [user.id])
        task.update(summary: "New summary")
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

  describe "#update_issue_counts" do
    let(:issue) { Fabricate(:issue) }

    context "when creating a task without an issue" do
      it "doesn't raise an error" do
        expect do
          Fabricate(:open_task, issue: nil)
        end.not_to raise_error
      end
    end

    context "when creating an open task for an issue" do
      it "should change issue's open_tasks_count" do
        expect do
          Fabricate(:open_task, issue: issue)
        end.to change(issue, :open_tasks_count).to(1)
      end
    end

    context "when creating a closed task for an issue" do
      it "should not change issue's closed_tasks_count" do
        expect do
          Fabricate(:closed_task, issue: issue)
        end.not_to change(issue, :open_tasks_count).from(0)
      end
    end

    context "when closing an open task" do
      it "should change issue's closed_tasks_count" do
        task = Fabricate(:open_task, issue: issue)
        expect do
          task.close
          issue.reload
        end.to change(issue, :open_tasks_count).by(-1)
      end
    end
  end

  describe "#subscribe_user" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:subscriber) { Fabricate(:user_reporter) }

    context "when not provided a subscriber" do
      context "but task has a user" do
        let(:task) { Fabricate(:task, user: user) }

        context "that is not subscribed" do
          it "creates a task_subscription for the task user" do
            expect do
              task.subscribe_user
            end.to change(user.task_subscriptions, :count).by(1)
          end
        end

        context "that is already subscribed" do
          before do
            Fabricate(:task_subscription, task: task, user: user)
          end

          it "doesn't create a task_subscription" do
            expect do
              task.subscribe_user
            end.not_to change(TaskSubscription, :count)
          end
        end
      end

      context "and task doesn't have a user" do
        let(:task) { Fabricate.build(:task, user: nil) }

        it "doesn't create a task_subscription" do
          expect do
            task.subscribe_user
          end.not_to change(TaskSubscription, :count)
        end
      end
    end

    context "when provided a subscriber" do
      let(:task) { Fabricate(:task, user: user) }

      context "that is not subscribed" do
        it "creates a task_subscription for the subscriber" do
          expect do
            task.subscribe_user(subscriber)
          end.to change(subscriber.task_subscriptions, :count).by(1)
        end

        it "doesn't create a task_subscription for the task user" do
          expect do
            task.subscribe_user(subscriber)
          end.to change(TaskSubscription, :count).by(1)
        end
      end
    end
  end

  describe "#subscribe_assignees" do
    let(:user) { Fabricate(:user_reviewer) }

    context "when assignee" do
      let(:task) { Fabricate(:task, assignee_ids: [user.id]) }

      context "not subscribed" do
        it "creates a task_subscription for the user" do
          expect do
            task.subscribe_assignees
          end.to change(user.task_subscriptions, :count).by(1)
        end
      end

      context "already subscribed" do
        before do
          Fabricate(:task_subscription, task: task, user: user)
        end

        it "doesn't create a task_subscription" do
          expect do
            task.subscribe_assignees
          end.not_to change(TaskSubscription, :count)
        end
      end
    end

    context "when no assignees" do
      let(:task) { Fabricate(:task, assignee_ids: nil) }

      it "doesn't create a task_subscription" do
        expect do
          task.subscribe_assignees
        end.not_to change(TaskSubscription, :count)
      end
    end
  end

  describe "#subscribe_users" do
    let(:user) { Fabricate(:user_reviewer) }
    let(:task) { Fabricate(:task, user: user, project: project) }

    it "runs subscribe_user" do
      expect(task).to receive(:subscribe_user)
      task.subscribe_users
    end

    it "runs subscribe_assignees" do
      expect(task).to receive(:subscribe_assignees)
      task.subscribe_users
    end

    context "when task category has a subscriber" do
      let(:subscriber) { Fabricate(:user_reporter) }

      before do
        Fabricate(:category_tasks_subscription, category: category,
                                                user: subscriber)
      end

      it "creates a task_subscription for the subscriber" do
        expect do
          task.subscribe_users
        end.to change(subscriber.task_subscriptions, :count).by(1)
      end

      it "creates 2 task_subscriptions" do
        expect do
          task.subscribe_users
        end.to change(TaskSubscription, :count).by(2)
      end
    end

    context "when task project has a subscriber" do
      let(:subscriber) { Fabricate(:user_reporter) }

      before do
        Fabricate(:project_tasks_subscription, project: project,
                                              user: subscriber)
      end

      it "creates a task_subscription for the subscriber" do
        expect do
          task.subscribe_users
        end.to change(subscriber.task_subscriptions, :count).by(1)
      end

      it "creates 2 task_subscriptions" do
        expect do
          task.subscribe_users
        end.to change(TaskSubscription, :count).by(2)
      end
    end

    context "when task category/project subscriber" do
      let(:subscriber) { Fabricate(:user_reporter) }

      before do
        Fabricate(:project_tasks_subscription, project: project,
                                              user: subscriber)
        Fabricate(:category_tasks_subscription, category: category,
                                                user: subscriber)
      end

      it "creates a task_subscription for the subscriber" do
        expect do
          task.subscribe_users
        end.to change(subscriber.task_subscriptions, :count).by(1)
      end

      it "creates 2 task_subscriptions" do
        expect do
          task.subscribe_users
        end.to change(TaskSubscription, :count).by(2)
      end
    end
  end
end
