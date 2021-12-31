# frozen_string_literal: true

require "rails_helper"

RSpec.describe Project, type: :model do
  let(:category) { Fabricate(:category) }

  before do
    @project = Project.new(name: "Project Name", category_id: category.id)
  end

  subject { @project }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:visible) }
  it { is_expected.to respond_to(:internal) }
  it { is_expected.to respond_to(:category_id) }

  it { is_expected.to belong_to(:category).required }

  it { is_expected.to have_many(:issues) }
  it { is_expected.to have_many(:tasks) }
  it { is_expected.to have_many(:project_issues_subscriptions) }
  it { is_expected.to have_many(:project_tasks_subscriptions) }
  it { is_expected.to have_many(:issue_subscribers) }
  it { is_expected.to have_many(:task_subscribers) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_presence_of(:name) }
  it do
    is_expected.to validate_uniqueness_of(:name)
      .case_insensitive.scoped_to(:category_id)
  end
  it { is_expected.to validate_length_of(:name).is_at_most(250) }

  # CLASS

  describe ".all_visible" do
    let(:category) { Fabricate(:category) }
    let(:invisible_category) { Fabricate(:invisible_category) }

    before do
      Fabricate(:invisible_project)
    end

    it "returns projects with true visible and visible category" do
      project = Fabricate(:project)
      invisible_category_project =
        Fabricate(:project, category: invisible_category)

      expect(Project.all_visible)
        .to contain_exactly(project, invisible_category_project)
    end
  end

  describe ".all_invisible" do
    let(:category) { Fabricate(:category) }
    let(:invisible_category) { Fabricate(:invisible_category) }

    before do
      Fabricate(:project)
      Fabricate(:project, category: invisible_category)
    end

    it "returns projects with true visible and visible category" do
      invisible_project = Fabricate(:invisible_project)

      expect(Project.all_invisible).to contain_exactly(invisible_project)
    end
  end

  # INSTANCE

  describe "#issues" do
    let(:project) { Fabricate(:project) }

    context "when destroying Project" do
      it "destroys its issues" do
        Fabricate(:issue, project: project)
        Fabricate(:issue)

        expect do
          project.destroy
        end.to change(Issue, :count).by(-1)
      end
    end
  end

  describe "#tasks" do
    let(:project) { Fabricate(:project) }

    context "when destroying Project" do
      it "destroys its tasks" do
        Fabricate(:task, project: project)
        Fabricate(:task)

        expect do
          project.destroy
        end.to change(Task, :count).by(-1)
      end
    end
  end

  describe "#issues_subscription" do
    let(:user) { Fabricate(:user_worker) }
    let(:project) { Fabricate(:project) }

    before do
      Fabricate(:project_issues_subscription, user: user)
      Fabricate(:project_issues_subscription, project: project)
    end

    context "when no options" do
      context "when no subscription for the project" do
        it "returns nil" do
          expect(project.issues_subscription(user)).to be_nil
        end
      end

      context "when subscription for the project" do
        let(:subscription) do
          Fabricate(:project_issues_subscription, user: user, project: project)
        end

        before { subscription }

        it "returns it" do
          expect(project.issues_subscription(user)).to eq(subscription)
        end
      end
    end

    context "when init is true" do
      context "when no subscription for the project" do
        it "returns a new one" do
          expect(project.issues_subscription(user, init: true))
            .to be_a_new(ProjectIssuesSubscription)
        end
      end

      context "when subscription for the project" do
        let(:subscription) do
          Fabricate(:project_issues_subscription, user: user, project: project)
        end

        before { subscription }

        it "returns it" do
          expect(project.issues_subscription(user, init: true))
            .to eq(subscription)
        end
      end
    end
  end

  describe "#tasks_subscription" do
    let(:user) { Fabricate(:user_worker) }
    let(:project) { Fabricate(:project) }

    before do
      Fabricate(:project_tasks_subscription, user: user)
      Fabricate(:project_tasks_subscription, project: project)
    end

    context "when no options" do
      context "when no subscription for the project" do
        it "returns nil" do
          expect(project.tasks_subscription(user)).to be_nil
        end
      end

      context "when subscription for the project" do
        let(:subscription) do
          Fabricate(:project_tasks_subscription, user: user, project: project)
        end

        before { subscription }

        it "returns it" do
          expect(project.tasks_subscription(user)).to eq(subscription)
        end
      end
    end

    context "when init is true" do
      context "when no subscription for the project" do
        it "returns a new one" do
          expect(project.tasks_subscription(user, init: true))
            .to be_a_new(ProjectTasksSubscription)
        end
      end

      context "when subscription for the project" do
        let(:subscription) do
          Fabricate(:project_tasks_subscription, user: user, project: project)
        end

        before { subscription }

        it "returns it" do
          expect(project.tasks_subscription(user, init: true))
            .to eq(subscription)
        end
      end
    end
  end

  describe "#subscribed_to_issues?" do
    let(:user) { Fabricate(:user_worker) }
    let(:project) { Fabricate(:project) }

    before do
      Fabricate(:project_issues_subscription, user: user)
      Fabricate(:project_issues_subscription, project: project)
    end

    context "when no subscription for the project" do
      it "returns false" do
        expect(project.subscribed_to_issues?(user)).to eq(false)
      end
    end

    context "when subscription for the project" do
      let(:subscription) do
        Fabricate(:project_issues_subscription, user: user, project: project)
      end

      before { subscription }

      it "returns true" do
        expect(project.subscribed_to_issues?(user)).to eq(true)
      end
    end
  end

  describe "#subscribed_to_tasks?" do
    let(:user) { Fabricate(:user_worker) }
    let(:project) { Fabricate(:project) }

    before do
      Fabricate(:project_tasks_subscription, user: user)
      Fabricate(:project_tasks_subscription, project: project)
    end

    context "when no subscription for the project" do
      it "returns false" do
        expect(project.subscribed_to_tasks?(user)).to eq(false)
      end
    end

    context "when subscription for the project" do
      let(:subscription) do
        Fabricate(:project_tasks_subscription, user: user, project: project)
      end

      before { subscription }

      it "returns true" do
        expect(project.subscribed_to_tasks?(user)).to eq(true)
      end
    end
  end

  describe "#totally_visible?" do
    context "when visible is true" do
      context "and category visible is true" do
        let(:category) { Fabricate(:category) }
        let(:project) { Fabricate(:project, category: category) }

        it "returns true" do
          expect(project.totally_visible?).to eq(true)
        end
      end

      context "and category visible is false" do
        let(:category) { Fabricate(:invisible_category) }
        let(:project) { Fabricate(:project, category: category) }

        it "returns false" do
          expect(project.totally_visible?).to eq(false)
        end
      end

      context "and no category" do
        let(:project) { Fabricate(:project) }

        before { project.category = nil }

        it "returns false" do
          expect(project.totally_visible?).to eq(false)
        end
      end
    end

    context "when visible is false" do
      let(:category) { Fabricate(:category) }
      let(:project) { Fabricate(:invisible_project, category: category) }

      it "returns false" do
        expect(project.totally_visible?).to eq(false)
      end
    end
  end
end
