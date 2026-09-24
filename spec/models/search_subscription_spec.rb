require "rails_helper"

RSpec.describe SearchSubscription, type: :model do
  include TestMethods

  let(:user) { Fabricate(:user) }

  before do
    @search_subscription =
      SearchSubscription.new(user_id: user.id, term: "Search")
  end

  subject { @search_subscription }

  it { is_expected.to respond_to(:user_id) }
  it { is_expected.to respond_to(:include_issues) }
  it { is_expected.to respond_to(:include_tasks) }
  it { is_expected.to respond_to(:term) }
  it { is_expected.to respond_to(:issue_type_id) }
  it { is_expected.to respond_to(:task_type_id) }
  it { is_expected.to respond_to(:issue_status) }
  it { is_expected.to respond_to(:task_status) }
  it { is_expected.to respond_to(:source_user_id) }
  it { is_expected.to respond_to(:category_id) }
  it { is_expected.to respond_to(:project_id) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:source_user).optional }
  it { is_expected.to belong_to(:category).optional }
  it { is_expected.to belong_to(:project).optional }
  it { is_expected.to belong_to(:issue_type).optional }
  it { is_expected.to belong_to(:task_type).optional }

  it { is_expected.to be_valid }

  it { is_expected.to validate_length_of(:term).is_at_most(50) }
  it do
    is_expected
      .to validate_uniqueness_of(:user_id)
      .scoped_to(%i[term issue_status task_status issue_type_id task_type_id
                    project_id category_id])
  end

  describe "#validates" do
    describe "any_search_parameter" do
      before do
        subject.term = nil
        subject.include_issues = false
        subject.include_tasks = false
      end

      context "when term is not set" do
        it { is_expected.not_to be_valid }
      end

      context "when only issue_type_id is set" do
        before do
          subject.issue_type_id = Fabricate(:issue_type).id
        end

        context "and include_issues is true" do
          before do
            subject.include_issues = true
          end

          it { is_expected.to be_valid }
        end

        context "and include_issues is false" do
          before do
            subject.include_issues = false
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when only task_type_id is set" do
        before do
          subject.task_type_id = Fabricate(:task_type).id
        end

        context "and include_tasks is true" do
          before do
            subject.include_tasks = true
          end

          it { is_expected.to be_valid }
        end

        context "and include_tasks is false" do
          before do
            subject.include_tasks = false
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when only issue_status is set" do
        before do
          subject.include_issues = true
          subject.issue_status = "pending"
          subject.task_status = ""
        end

        it { is_expected.to be_valid }
      end

      context "when only task_status is set" do
        before do
          subject.include_tasks = true
          subject.issue_status = ""
          subject.task_status = "assigned"
        end

        it { is_expected.to be_valid }
      end

      context "when only source_user_id is set" do
        before do
          subject.include_issues = true
          subject.source_user_id = Fabricate(:user).id
        end

        it { is_expected.to be_valid }
      end

      context "when only category_id is set" do
        before do
          subject.include_issues = true
          subject.category_id = Fabricate(:category).id
        end

        it { is_expected.to be_valid }
      end

      context "when only project_id is set" do
        before do
          subject.include_issues = true
          subject.project_id = Fabricate(:project).id
        end

        it { is_expected.to be_valid }
      end
    end

    describe "either_include_issues_or_tasks" do
      before do
        subject.include_issues = false
        subject.include_tasks = false
      end

      context "when both include_issues and include_tasks are false" do
        it { is_expected.not_to be_valid }
      end

      context "when include_issues is true" do
        before do
          subject.include_issues = true
        end

        it { is_expected.to be_valid }
      end

      context "when include_tasks is true" do
        before do
          subject.include_tasks = true
        end

        it { is_expected.to be_valid }
      end
    end

    describe "#either_issue_attrs_or_task_attrs" do
      context "when both include_issues and include_tasks is true" do
        before do
          subject.include_issues = true
          subject.include_tasks = true
        end

        context "when only term is set" do
          before do
            subject.term = "something"
          end

          it { is_expected.to be_valid }
        end

        context "when issue_type_id is set" do
          before do
            subject.issue_type_id = Fabricate(:issue_type).id
          end

          it { is_expected.not_to be_valid }
        end

        context "when issue_status is set" do
          before do
            subject.issue_status = "resolved"
          end

          it { is_expected.not_to be_valid }
        end

        context "when task_type_id is set" do
          before do
            subject.task_type_id = Fabricate(:task_type).id
          end

          it { is_expected.not_to be_valid }
        end

        context "when task_status is set" do
          before do
            subject.task_status = "in_review"
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when only include_issues is true" do
        before do
          subject.include_issues = true
          subject.include_tasks = false
        end

        context "when only term is set" do
          before do
            subject.term = "something"
          end

          it { is_expected.to be_valid }
        end

        context "when issue_type_id is set" do
          before do
            subject.issue_type_id = Fabricate(:issue_type).id
          end

          it { is_expected.to be_valid }
        end

        context "when issue_status is set" do
          before do
            subject.issue_status = "resolved"
          end

          it { is_expected.to be_valid }
        end

        context "when isssue_type_id and isssue_status are set" do
          before do
            subject.issue_type_id = Fabricate(:issue_type).id
            subject.issue_status = "resolved"
          end

          it { is_expected.to be_valid }
        end

        context "when task_type_id is set" do
          before do
            subject.task_type_id = Fabricate(:task_type).id
          end

          it { is_expected.not_to be_valid }
        end

        context "when task_status is set" do
          before do
            subject.task_status = "in_review"
          end

          it { is_expected.not_to be_valid }
        end
      end

      context "when only include_tasks is true" do
        before do
          subject.include_issues = false
          subject.include_tasks = true
        end

        context "when only term is set" do
          before do
            subject.term = "something"
          end

          it { is_expected.to be_valid }
        end

        context "when issue_type_id is set" do
          before do
            subject.issue_type_id = Fabricate(:issue_type).id
          end

          it { is_expected.not_to be_valid }
        end

        context "when issue_status is set" do
          before do
            subject.issue_status = "resolved"
          end

          it { is_expected.not_to be_valid }
        end

        context "when task_type_id is set" do
          before do
            subject.task_type_id = Fabricate(:task_type).id
          end

          it { is_expected.to be_valid }
        end

        context "when task_status is set" do
          before do
            subject.task_status = "in_review"
          end

          it { is_expected.to be_valid }
        end

        context "when task_type_id and task_status are set" do
          before do
            subject.task_type_id = Fabricate(:task_type).id
            subject.task_status = "in_review"
          end

          it { is_expected.to be_valid }
        end
      end
    end
  end

  describe "#toggle" do
    context "for an active SearchSubscription" do
      let(:search_subscription) { Fabricate(:search_subscription) }

      it "changes active to false" do
        expect do
          search_subscription.toggle
          search_subscription.reload
        end.to change(search_subscription, :active).to(false)
      end
    end

    context "for an inactive SearchSubscription" do
      let(:search_subscription) { Fabricate(:inactive_search_subscription) }

      it "changes active to true" do
        expect do
          search_subscription.toggle
          search_subscription.reload
        end.to change(search_subscription, :active).to(true)
      end
    end
  end

  describe "#search_results" do
    let(:first_category) { Fabricate(:category) }
    let(:first_project) { Fabricate(:project, category: first_category) }
    let(:second_project) { Fabricate(:project, category: first_category) }
    let(:first_user) { Fabricate(:user) }
    let(:first_issue_type) { Fabricate(:issue_type) }
    let(:first_task_type) { Fabricate(:task_type) }

    let(:invisible_project) do
      Fabricate(:invisible_project, category: first_category)
    end

    before do
      Fabricate(:issue, summary: "Beta", status: "pending")
      Fabricate(:task, summary: "Gamma", status: "unassigned")
    end

    context "when term is set" do
      let!(:first_issue) { Fabricate(:issue, summary: "Mostly Alpha Issue") }
      let!(:first_task) do
        Fabricate(:task, summary: "Task", description: "Definitely alpha")
      end

      before do
        Fabricate(:issue, project: invisible_project, summary: "alpha")
        Fabricate(:task, project: invisible_project, summary: "alpha")
      end

      context "and including issues and tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "alpha",
                                          include_issues: true,
                                          include_tasks: true)
        end

        it "returns visible issues/tasks with matching summary/description" do
          expect(map_class_id(search_subscription.search_results))
            .to contain_exactly(["Issue", first_issue.id],
                                ["Task", first_task.id])
        end
      end

      context "and including only issues" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "alpha",
                                          include_issues: true,
                                          include_tasks: false)
        end

        it "returns issues and tasks with matching summary/description" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Issue", first_issue.id]])
        end
      end

      context "and including only tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "alpha",
                                          include_issues: false,
                                          include_tasks: true)
        end

        it "returns issues and tasks with matching summary/description" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Task", first_task.id]])
        end
      end
    end

    context "when category_id is set" do
      let!(:first_issue) { Fabricate(:issue, project: first_project) }
      let!(:first_task) { Fabricate(:task, project: second_project) }

      before do
        Fabricate(:issue, project: invisible_project)
        Fabricate(:task, project: invisible_project)
      end

      context "and including issues and tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          category: first_category,
                                          include_issues: true,
                                          include_tasks: true)
        end

        it "returns visible issues and tasks with matching category" do
          expect(map_class_id(search_subscription.search_results))
            .to contain_exactly(["Issue", first_issue.id],
                                ["Task", first_task.id])
        end
      end

      context "and including only issues" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          category: first_category,
                                          include_issues: true,
                                          include_tasks: false)
        end

        it "returns visible issues with matching category" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Issue", first_issue.id]])
        end
      end

      context "and including only tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          category: first_category,
                                          include_issues: false,
                                          include_tasks: true)
        end

        it "returns visible tasks with matching category" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Task", first_task.id]])
        end
      end
    end

    context "when project_id is set" do
      let!(:first_issue) { Fabricate(:issue, project: first_project) }
      let!(:first_task) { Fabricate(:task, project: first_project) }

      context "for a visible project" do
        context "when including issues and tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: true,
                                            include_tasks: true)
          end

          it "returns issues and tasks with matching project" do
            expect(map_class_id(search_subscription.search_results))
              .to contain_exactly(["Issue", first_issue.id],
                                  ["Task", first_task.id])
          end
        end

        context "when including only issues" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: true,
                                            include_tasks: false)
          end

          it "returns issues with matching project" do
            expect(map_class_id(search_subscription.search_results))
              .to eq([["Issue", first_issue.id]])
          end
        end

        context "when including only tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: false,
                                            include_tasks: true)
          end

          it "returns tasks with matching project" do
            expect(map_class_id(search_subscription.search_results))
              .to eq([["Task", first_task.id]])
          end
        end
      end

      context "for an internal project" do
        let(:first_project) { Fabricate(:internal_project) }

        context "when including issues and tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: true,
                                            include_tasks: true)
          end

          it "returns issues and tasks with matching project" do
            expect(map_class_id(search_subscription.search_results))
              .to contain_exactly(["Issue", first_issue.id],
                                  ["Task", first_task.id])
          end
        end

        context "when including only issues" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: true,
                                            include_tasks: false)
          end

          it "returns issues with matching project" do
            expect(map_class_id(search_subscription.search_results))
              .to eq([["Issue", first_issue.id]])
          end
        end

        context "when including only tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: false,
                                            include_tasks: true)
          end

          it "returns tasks with matching project" do
            expect(map_class_id(search_subscription.search_results))
              .to eq([["Task", first_task.id]])
          end
        end
      end

      context "for an invisible project" do
        let(:first_project) { Fabricate(:invisible_project) }

        context "when including issues and tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: true,
                                            include_tasks: true)
          end

          it "returns issues and tasks with matching project" do
            expect(search_subscription.search_results).to eq([])
          end
        end

        context "when including only issues" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: true,
                                            include_tasks: false)
          end

          it "returns issues with matching project" do
            expect(search_subscription.search_results).to eq([])
          end
        end

        context "when including only tasks" do
          let(:search_subscription) do
            Fabricate(:search_subscription, term: "",
                                            project: first_project,
                                            include_issues: false,
                                            include_tasks: true)
          end

          it "returns tasks with matching project" do
            expect(search_subscription.search_results).to eq([])
          end
        end
      end
    end

    context "when issue_type_id is set" do
      let!(:first_issue) { Fabricate(:issue, issue_type: first_issue_type) }
      let!(:first_task) { Fabricate(:task, task_type: first_task_type) }

      context "and including only issues" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          issue_type: first_issue_type,
                                          include_issues: true,
                                          include_tasks: false)
        end

        it "returns issues with matching issue_type" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Issue", first_issue.id]])
        end
      end
    end

    context "when task_type_id is set" do
      let!(:first_issue) { Fabricate(:issue, issue_type: first_issue_type) }
      let!(:first_task) { Fabricate(:task, task_type: first_task_type) }

      context "and including only tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          task_type: first_task_type,
                                          include_issues: false,
                                          include_tasks: true)
        end

        it "returns tasks with matching task_type" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Task", first_task.id]])
        end
      end
    end

    context "when issue_status is set" do
      let!(:first_issue) { Fabricate(:issue, status: "being_worked_on") }
      let!(:first_task) { Fabricate(:task, status: "assigned") }

      context "and including only issues" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          issue_status: "being_worked_on",
                                          task_status: "",
                                          include_issues: true,
                                          include_tasks: false)
        end

        it "returns issues with matching issue_type" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Issue", first_issue.id]])
        end
      end
    end

    context "when task_status is set" do
      let!(:first_issue) { Fabricate(:issue, status: "being_worked_on") }
      let!(:first_task) { Fabricate(:task, status: "assigned") }

      context "and including only tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          issue_status: "",
                                          task_status: "assigned",
                                          include_issues: false,
                                          include_tasks: true)
        end

        it "returns tasks with matching task_type" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Task", first_task.id]])
        end
      end
    end

    context "when source_user_id is set" do
      let!(:first_issue) { Fabricate(:issue, user: first_user) }
      let!(:first_task) { Fabricate(:task, user: first_user) }

      context "and including issues and tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          source_user: first_user,
                                          include_issues: true,
                                          include_tasks: true)
        end

        it "returns issues and tasks with matching project" do
          expect(map_class_id(search_subscription.search_results))
            .to contain_exactly(["Issue", first_issue.id],
                                ["Task", first_task.id])
        end
      end

      context "and including only issues" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          source_user: first_user,
                                          include_issues: true,
                                          include_tasks: false)
        end

        it "returns issues with matching project" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Issue", first_issue.id]])
        end
      end

      context "and including only tasks" do
        let(:search_subscription) do
          Fabricate(:search_subscription, term: "",
                                          source_user: first_user,
                                          include_issues: false,
                                          include_tasks: true)
        end

        it "returns tasks with matching project" do
          expect(map_class_id(search_subscription.search_results))
            .to eq([["Task", first_task.id]])
        end
      end
    end
  end

  describe "#title" do
    let(:user) { Fabricate(:user) }
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project) }
    let(:issue_type) { Fabricate(:issue_type) }
    let(:task_type) { Fabricate(:task_type) }

    context "when including issues and task" do
      context "for a term" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true,
                                          term: "search term")
        end

        let(:title) { 'Issues and Tasks that match "search term"' }

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for a source_user and term" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true,
                                          source_user: user,
                                          term: "search term")
        end

        let(:title) do
          "Issues and Tasks from #{user.name} that match \"search term\""
        end

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for a category" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true,
                                          term: "",
                                          category: category)
        end

        let(:title) { "Issues and Tasks from #{category.name}" }

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for a project" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true,
                                          term: "",
                                          project: project)
        end

        let(:title) { "Issues and Tasks from #{project.name}" }

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for a project and term" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true,
                                          term: "search term",
                                          project: project)
        end

        let(:title) do
          "Issues and Tasks from #{project.name} that match \"search term\""
        end

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for a project, user and term" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true,
                                          source_user: user,
                                          term: "search term",
                                          project: project)
        end

        let(:title) do
          "Issues and Tasks from #{user.name} that match \"search term\""
        end

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end
    end

    context "when including only issues" do
      context "for a term" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false,
                                          term: "search term")
        end

        let(:title) { 'Issues that match "search term"' }

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for project and issue_type" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false,
                                          term: "",
                                          project: project,
                                          issue_type: issue_type)
        end

        let(:title) { "#{issue_type.name} Issues from #{project.name}" }

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for an issue_status and issue_type" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false,
                                          term: "",
                                          issue_status: "being_worked_on",
                                          issue_type: issue_type)
        end

        let(:title) { "#{issue_type.name} Issues with Being Worked On status" }

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end
    end

    context "when including only tasks" do
      context "for a user, task_type, and term" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true,
                                          term: "search term",
                                          source_user: user,
                                          task_type: task_type)
        end

        let(:title) do
          "#{task_type.name} Tasks from #{user.name} that match " \
            '"search term"'
        end

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for a category, user, and task_type" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true,
                                          term: "",
                                          category: category,
                                          source_user: user,
                                          task_type: task_type)
        end

        let(:title) { "#{task_type.name} Tasks from #{user.name}" }

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end

      context "for a task_type and task_status" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true,
                                          term: "",
                                          issue_status: "",
                                          task_status: "in_progress",
                                          task_type: task_type)
        end

        let(:title) do
          "#{task_type.name.titleize} Tasks with In Progress status"
        end

        it "returns title" do
          expect(search_subscription.title).to eq(title)
        end
      end
    end
  end

  describe "#filter_params" do
    let(:source_user) { Fabricate(:user) }
    let(:issue_type) { Fabricate(:issue_type) }
    let(:task_type) { Fabricate(:task_type) }
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project) }

    context "when include_issues and include_tasks are true" do
      context "while term is set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go")
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params).to eq({ query: "go" })
        end
      end

      context "while source_user_id and term are set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go",
                                          source_user: source_user)
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params).to eq({ query: "go" })
        end
      end

      context "while category_id and term are set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go",
                                          category: category)
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params).to eq({ query: "go" })
        end
      end

      context "while project_id and term are set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go",
                                          project: project)
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params).to eq({ query: "go" })
        end
      end
    end

    context "when include_issues is true" do
      context "while term is set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false, term: "go")
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params).to eq({ query: "go" })
        end
      end

      context "while term and issue_status are set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false, term: "go",
                                          issue_status: "pending")
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params)
            .to eq({ query: "go", issue_status: "pending" })
        end
      end

      context "while issue_status and issue_type_id are set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false,
                                          term: "",
                                          issue_status: "pending",
                                          issue_type: issue_type)
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params)
            .to eq({ issue_status: "pending", issue_type_id: issue_type.id })
        end
      end
    end

    context "when include_tasks is true" do
      context "while term is set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true, term: "go")
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params).to eq({ query: "go" })
        end
      end

      context "while term and task_status are set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true, term: "go",
                                          task_status: "unassigned")
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params)
            .to eq({ query: "go", task_status: "unassigned" })
        end
      end

      context "while task_status and task_type_id are set" do
        let(:search_subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true,
                                          term: "",
                                          task_status: "assigned",
                                          task_type: task_type)
        end

        it "converts attrs to filter params" do
          expect(search_subscription.filter_params)
            .to eq({ task_status: "assigned", task_type_id: task_type.id })
        end
      end
    end
  end
end
