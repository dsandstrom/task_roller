require "rails_helper"

RSpec.describe SearchFiltersConverter, type: :class do
  describe ".convert_params_to_attrs" do
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project) }
    let(:source_user) { Fabricate(:user) }
    let(:issue_type) { Fabricate(:issue_type) }
    let(:task_type) { Fabricate(:task_type) }

    context "when empty starting attrs" do
      context "and empty params" do
        let(:params) { {} }

        it "returns default attrs" do
          expect(described_class.convert_params_to_attrs(params))
            .to eq({ include_issues: true, include_tasks: true, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "and params contains 'issues' type" do
        let(:params) { { type: "issues" } }

        it "returns attrs with include_tasks false" do
          expect(described_class.convert_params_to_attrs(params))
            .to eq({ include_issues: true, include_tasks: false, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "and params contains 'tasks' type" do
        let(:params) { { type: "tasks" } }

        it "returns attrs with include_issues false" do
          expect(described_class.convert_params_to_attrs(params))
            .to eq({ include_issues: false, include_tasks: true, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "and params contains 'issues' type with full params" do
        let(:params) do
          { type: "issues", issue_type_id: issue_type.id,
            task_type_id: task_type.id, issue_status: "pending",
            task_status: "assigned" }
        end

        it "clears task params" do
          expect(described_class.convert_params_to_attrs(params))
            .to eq({ include_issues: true, include_tasks: false, term: nil,
                     issue_type_id: issue_type.id, issue_status: "pending",
                     task_type_id: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "and params contains 'tasks' type with full params" do
        let(:params) do
          { type: "tasks", issue_type_id: issue_type.id,
            task_type_id: task_type.id, issue_status: "pending",
            task_status: "assigned" }
        end

        it "clears issue params" do
          expect(described_class.convert_params_to_attrs(params))
            .to eq({ include_issues: false, include_tasks: true, term: nil,
                     task_type_id: task_type.id, task_status: "assigned",
                     issue_type_id: nil, issue_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "and params contains 'all' type with full params" do
        let(:params) do
          { type: "all", issue_type_id: issue_type.id,
            task_type_id: task_type.id, issue_status: "pending",
            task_status: "assigned" }
        end

        it "clears issue and task params" do
          expect(described_class.convert_params_to_attrs(params))
            .to eq({ include_issues: true, include_tasks: true, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end
    end

    context "when starting attrs contains category_id" do
      let(:attrs) { { category_id: category.id } }

      context "for empty params" do
        let(:params) { {} }

        it "returns attrs with category_id" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: true, include_tasks: true, term: nil,
                     category_id: category.id, issue_type_id: nil,
                     task_type_id: nil, issue_status: nil, task_status: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "for query param" do
        let(:params) { { query: "query" } }

        it "converts to attrs" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: true, include_tasks: true, term: "query",
                     category_id: category.id, issue_type_id: nil,
                     task_type_id: nil, issue_status: nil, task_status: nil,
                     project_id: nil, source_user_id: nil })
        end
      end
    end

    context "when starting attrs contains project_id" do
      let(:attrs) { { project_id: project.id } }

      context "for empty params" do
        let(:params) { {} }

        it "returns attrs with project_id" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: true, include_tasks: true,
                     project_id: project.id, term: nil, issue_type_id: nil,
                     task_type_id: nil, issue_status: nil, task_status: nil,
                     category_id: nil, source_user_id: nil })
        end
      end

      context "for query param" do
        let(:params) { { query: "query" } }

        it "converts to attrs" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: true, include_tasks: true, term: "query",
                     project_id: project.id, issue_type_id: nil,
                     task_type_id: nil, issue_status: nil, task_status: nil,
                     category_id: nil, source_user_id: nil })
        end
      end
    end

    context "when starting attrs contains include_issues false" do
      let(:attrs) { { include_issues: false } }

      context "for empty params" do
        let(:params) { {} }

        it "returns attrs with include_issues false" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: false, include_tasks: true, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "for task params" do
        let(:params) do
          { task_type_id: task_type.id, task_status: "in_progress" }
        end

        it "converts to attrs" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: false, include_tasks: true,
                     task_status: "in_progress", task_type_id: task_type.id,
                     term: nil, issue_type_id: nil, issue_status: nil,
                     category_id: nil, project_id: nil, source_user_id: nil })
        end
      end

      context "for task_status all and task_type_id all" do
        let(:params) { { task_type_id: "all", task_status: "all" } }

        it "clears them" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: false, include_tasks: true, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end
    end

    context "when starting attrs contains include_tasks false" do
      let(:attrs) { { include_tasks: false } }

      context "for empty params" do
        let(:params) { {} }

        it "returns attrs with include_tasks false" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: true, include_tasks: false, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end

      context "for issue params" do
        let(:params) do
          { issue_type_id: issue_type.id, issue_status: "in_progress" }
        end

        it "converts to attrs" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: true, include_tasks: false,
                     issue_status: "in_progress", issue_type_id: issue_type.id,
                     term: nil, task_type_id: nil, task_status: nil,
                     category_id: nil, project_id: nil, source_user_id: nil })
        end
      end

      context "for issue_status all and issue_type_id all" do
        let(:params) { { issue_type_id: "all", issue_status: "all" } }

        it "ignores them" do
          expect(described_class.convert_params_to_attrs(params, attrs))
            .to eq({ include_issues: true, include_tasks: false, term: nil,
                     issue_type_id: nil, task_type_id: nil,
                     issue_status: nil, task_status: nil, category_id: nil,
                     project_id: nil, source_user_id: nil })
        end
      end
    end
  end

  describe ".convert_attrs_to_filter_params" do
    let(:source_user) { Fabricate(:user) }
    let(:issue_type) { Fabricate(:issue_type) }
    let(:task_type) { Fabricate(:task_type) }
    let(:category) { Fabricate(:category) }
    let(:project) { Fabricate(:project) }

    context "when include_issues and include_tasks are true" do
      context "while term is set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go")
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", order: "updated,desc" })
        end
      end

      context "while source_user_id and term are set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go",
                                          source_user: source_user)
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", order: "updated,desc" })
        end
      end

      context "while category_id and term are set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go",
                                          category: category)
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", order: "updated,desc" })
        end
      end

      context "while project_id and term are set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: true, term: "go",
                                          project: project)
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", order: "updated,desc" })
        end
      end
    end

    context "when include_issues is true" do
      context "while term is set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false, term: "go")
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", type: "issues", issue_type_id: "all",
                     issue_status: "all", order: "updated,desc" })
        end
      end

      context "while term and issue_status are set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false, term: "go",
                                          issue_status: "pending")
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", type: "issues", issue_status: "pending",
                     issue_type_id: "all", order: "updated,desc" })
        end
      end

      context "while issue_status and issue_type_id are set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: true,
                                          include_tasks: false,
                                          term: "",
                                          issue_status: "pending",
                                          issue_type: issue_type)
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ type: "issues", issue_status: "pending",
                     issue_type_id: issue_type.id, order: "updated,desc" })
        end
      end
    end

    context "when include_tasks is true" do
      context "while term is set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true, term: "go")
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", type: "tasks", task_status: "all",
                     task_type_id: "all", order: "updated,desc" })
        end
      end

      context "while term and task_status are set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true, term: "go",
                                          task_status: "unassigned")
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ query: "go", type: "tasks", task_status: "unassigned",
                     task_type_id: "all", order: "updated,desc" })
        end
      end

      context "while task_status and task_type_id are set" do
        let(:subscription) do
          Fabricate(:search_subscription, include_issues: false,
                                          include_tasks: true,
                                          term: "",
                                          task_status: "assigned",
                                          task_type: task_type)
        end

        it "converts attrs to filter params" do
          expect(described_class.convert_attrs_to_filter_params(subscription))
            .to eq({ type: "tasks", task_status: "assigned",
                     task_type_id: task_type.id, order: "updated,desc" })
        end
      end
    end
  end
end
