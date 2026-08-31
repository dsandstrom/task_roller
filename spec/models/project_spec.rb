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
  it { is_expected.to respond_to(:position) }
  it { is_expected.to respond_to(:new_position) }

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

  describe "validate #new_position_numericality" do
    let(:project) { Fabricate(:project, category: category) }

    context "when nil" do
      before { project.new_position = nil }

      it { expect(project).to be_valid }
    end

    context "when blank" do
      before { project.new_position = "" }

      it { expect(project).to be_valid }
    end

    context "when string" do
      before { project.new_position = "something" }

      it { expect(project).not_to be_valid }
    end

    context "when 0" do
      before { project.new_position = 0 }

      it { expect(project).not_to be_valid }
    end

    context "when 1" do
      before do
        project.new_position = 1
      end

      it { expect(project).to be_valid }
    end

    context "when no category" do
      before do
        project.category = nil
        project.new_position = 1
      end

      it { expect(project).not_to be_valid }
    end

    context "when two projects" do
      before do
        Fabricate(:project)
        Fabricate(:project, category: category)
        project
        Fabricate(:project, category: category)
      end

      context "and given 1" do
        before { project.new_position = 1 }

        it { expect(project).to be_valid }
      end

      context "and given 3" do
        before { project.new_position = 3 }

        it { expect(project).to be_valid }
      end

      context "and given 4" do
        before { project.new_position = 4 }

        it { expect(project).not_to be_valid }
      end
    end
  end

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

  describe "#name_and_tag" do
    context "when category is visible" do
      let(:category) { Fabricate(:category) }

      context "and project is visible" do
        let(:project) { Fabricate(:project, category: category) }

        it "returns name only" do
          expect(project.name_and_tag).to eq(project.name)
        end
      end

      context "and project is invisible" do
        let(:project) { Fabricate(:invisible_project, category: category) }

        it "returns name and archived tag" do
          expect(project.name_and_tag).to eq("#{project.name} (archived)")
        end
      end

      context "and project is internal" do
        let(:project) { Fabricate(:internal_project, category: category) }

        it "returns name and internal tag" do
          expect(project.name_and_tag).to eq("#{project.name} (internal)")
        end
      end

      context "and project is invisible and internal" do
        let(:project) do
          Fabricate(:invisible_project, internal: true, category: category)
        end

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end
    end

    context "when category is invisible" do
      let(:category) { Fabricate(:invisible_category) }

      context "and project is visible" do
        let(:project) { Fabricate(:project, category: category) }

        it "returns name and archived tag" do
          expect(project.name_and_tag).to eq("#{project.name} (archived)")
        end
      end

      context "and project is invisible" do
        let(:project) { Fabricate(:invisible_project, category: category) }

        it "returns name and archived tag" do
          expect(project.name_and_tag).to eq("#{project.name} (archived)")
        end
      end

      context "and project is internal" do
        let(:project) { Fabricate(:internal_project, category: category) }

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end

      context "and project is invisible and internal" do
        let(:project) do
          Fabricate(:invisible_project, internal: true, category: category)
        end

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end
    end

    context "when category is internal" do
      let(:category) { Fabricate(:internal_category) }

      context "and project is visible" do
        let(:project) { Fabricate(:project, category: category) }

        it "returns name and internal tag" do
          expect(project.name_and_tag).to eq("#{project.name} (internal)")
        end
      end

      context "and project is invisible" do
        let(:project) { Fabricate(:invisible_project, category: category) }

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end

      context "and project is internal" do
        let(:project) { Fabricate(:internal_project, category: category) }

        it "returns name and internal tag" do
          expect(project.name_and_tag).to eq("#{project.name} (internal)")
        end
      end

      context "and project is invisible and internal" do
        let(:project) do
          Fabricate(:invisible_project, internal: true, category: category)
        end

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end
    end

    context "when category is internal and invisible" do
      let(:category) { Fabricate(:invisible_category, internal: true) }

      context "and project is visible" do
        let(:project) { Fabricate(:project, category: category) }

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end

      context "and project is invisible" do
        let(:project) { Fabricate(:invisible_project, category: category) }

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end

      context "and project is internal" do
        let(:project) { Fabricate(:internal_project, category: category) }

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end

      context "and project is invisible and internal" do
        let(:project) do
          Fabricate(:invisible_project, internal: true, category: category)
        end

        it "returns name and archived and internal tags" do
          expect(project.name_and_tag)
            .to eq("#{project.name} (archived, internal)")
        end
      end
    end
  end

  describe "#reposition" do
    let(:category) { Fabricate(:category) }
    let!(:first) { Fabricate(:project, category: category) }
    let!(:second) { Fabricate(:project, category: category) }
    let!(:third) { Fabricate(:project, category: category) }

    before do
      Fabricate(:project)
    end

    context "when new_position is 1" do
      before do
        third.new_position = 1
      end

      it "sorts project to first position" do
        expect do
          third.reposition
          third.reload
        end.to change(third, :position).from(3).to(1)
      end

      it "returns true" do
        expect(third.reposition).to be_truthy
      end
    end

    context "when new_position is 3" do
      before do
        second.new_position = 3
      end

      it "sorts project to third position" do
        expect do
          second.reposition
          second.reload
        end.to change(second, :position).from(2).to(3)
      end

      it "moves other categories" do
        expect do
          second.reposition
          third.reload
        end.to change(third, :position).from(3).to(2)
      end

      it "returns true" do
        expect(second.reposition).to be_truthy
      end
    end

    context "when first project and new_position is 1" do
      before do
        first.new_position = 1
      end

      it "doesn't change the project" do
        expect do
          first.reposition
          first.reload
        end.not_to change(first, :position)
      end

      it "returns false" do
        expect(first.reposition).to be_falsy
      end
    end

    context "when new_position is too large" do
      before do
        first.new_position = 10
      end

      it "doesn't change the project" do
        expect do
          first.reposition
          first.reload
        end.not_to change(first, :position)
      end

      it "returns false" do
        expect(first.reposition).to be_falsy
      end
    end

    context "when new_position is 0" do
      before do
        third.new_position = 0
      end

      it "doesn't change the project" do
        expect do
          third.reposition
          third.reload
        end.not_to change(third, :position)
      end

      it "returns false" do
        expect(third.reposition).to be_falsy
      end
    end

    context "when new_position is nil" do
      before do
        third.new_position = nil
      end

      it "doesn't change the project" do
        expect do
          third.reposition
          third.reload
        end.not_to change(third, :position)
      end

      it "returns false" do
        expect(third.reposition).to be_falsy
      end
    end
  end
end
