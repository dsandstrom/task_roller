# frozen_string_literal: true

require "rails_helper"

RSpec.describe TasksController, type: :controller do
  let(:task_type) { Fabricate(:task_type) }
  let(:user) { Fabricate(:user_reporter) }
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:issue) { Fabricate(:issue, project: project) }

  let(:valid_attributes) do
    { task_type_id: task_type.id, user_id: user.id, summary: "Summary",
      description: "Description" }
  end

  let(:invalid_attributes) { { summary: "" } }

  describe "GET #index" do
    context "when category only" do
      it "returns a success response" do
        _task = Fabricate(:task, project: project)
        get :index, params: { category_id: category.to_param }
        expect(response).to be_successful
      end
    end

    context "when category and project" do
      it "returns a success response" do
        _task = Fabricate(:task, project: project)
        get :index, params: { category_id: category.to_param,
                              project_id: project.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "GET #show" do
    context "when category only" do
      it "returns a success response" do
        task = Fabricate(:task, project: project)
        get :show, params: { category_id: category.to_param, id: task.to_param }
        expect(response).to be_successful
      end
    end

    context "when category and project" do
      it "returns a success response" do
        task = Fabricate(:task, project: project)
        get :show, params: { category_id: category.to_param,
                             project_id: project.to_param,
                             id: task.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "GET #new" do
    before { Fabricate(:task_type) }

    context "when category and project" do
      it "returns a success response" do
        get :new, params: { category_id: category.to_param,
                            project_id: project.to_param }

        expect(response).to be_successful
      end
    end

    context "when category, project, and issue" do
      it "returns a success response" do
        get :new, params: { category_id: category.to_param,
                            project_id: project.to_param,
                            issue_id: issue.to_param }

        expect(response).to be_successful
      end
    end
  end

  describe "GET #edit" do
    context "when category and project" do
      it "returns a success response" do
        task = Fabricate(:task, project: project)
        get :edit, params: { category_id: category.to_param,
                             project_id: project.to_param,
                             id: task.to_param }
        expect(response).to be_successful
      end
    end

    context "when category, project, and issue" do
      it "returns a success response" do
        task = Fabricate(:task, project: project, issue: issue)
        get :edit, params: { category_id: category.to_param,
                             project_id: project.to_param,
                             issue_id: issue.to_param,
                             id: task.to_param }
        expect(response).to be_successful
      end
    end
  end

  describe "POST #create" do
    context "when category and project" do
      context "with valid params" do
        it "creates a new Task" do
          expect do
            post :create, params: { category_id: category.to_param,
                                    project_id: project.to_param,
                                    task: valid_attributes }
          end.to change(project.tasks, :count).by(1)
        end

        it "redirects to the created task" do
          post :create, params: { category_id: category.to_param,
                                  project_id: project.to_param,
                                  task: valid_attributes }
          url = category_project_task_path(category, project, Task.last)
          expect(response).to redirect_to(url)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { category_id: category.to_param,
                                  project_id: project.to_param,
                                  task: invalid_attributes }
          expect(response).to be_successful
        end
      end

      context "when assigning" do
        let(:user) { Fabricate(:user_worker) }

        before { valid_attributes.merge!(assignee_ids: [user.id]) }

        it "creates an assignment" do
          expect do
            post :create, params: { category_id: category.to_param,
                                    project_id: project.to_param,
                                    task: valid_attributes }
          end.to change(user.assignments, :count).by(1)
        end
      end
    end

    context "when category, project, and issue" do
      context "with valid params" do
        it "creates a new Task" do
          expect do
            post :create, params: { category_id: category.to_param,
                                    project_id: project.to_param,
                                    issue_id: issue.to_param,
                                    task: valid_attributes }
          end.to change(issue.tasks, :count).by(1)
        end

        it "redirects to the created task" do
          post :create, params: { category_id: category.to_param,
                                  project_id: project.to_param,
                                  issue_id: issue.to_param,
                                  task: valid_attributes }
          url = category_project_task_path(category, project, Task.last)
          expect(response).to redirect_to(url)
        end
      end

      context "with invalid params" do
        it "returns a success response (i.e. to display the 'new' template)" do
          post :create, params: { category_id: category.to_param,
                                  project_id: project.to_param,
                                  issue_id: issue.to_param,
                                  task: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) { { summary: "New Summary" } }

      it "updates the requested task" do
        task = Fabricate(:task, project: project)
        expect do
          put :update, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: task.to_param,
                                 task: new_attributes }
          task.reload
        end.to change(task, :summary).to("New Summary")
      end

      it "redirects to the task" do
        task = Fabricate(:task, project: project)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: task.to_param,
                               task: new_attributes }
        expect(response)
          .to redirect_to(category_project_task_url(category, project, task))
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        task = Fabricate(:task, project: project)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               id: task.to_param,
                               task: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested task" do
      task = Fabricate(:task, project: project)
      expect do
        delete :destroy, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   id: task.to_param }
      end.to change(Task, :count).by(-1)
    end

    it "redirects to the tasks list" do
      task = Fabricate(:task, project: project)
      delete :destroy, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 id: task.to_param }
      expect(response).to redirect_to(category_project_url(category, project))
    end
  end
end
