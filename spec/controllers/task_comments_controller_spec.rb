# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskCommentsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }
  let(:user) { Fabricate(:user_worker) }

  let(:valid_attributes) { { user_id: user.id, body: "Body" } }

  let(:invalid_attributes) { { body: "" } }

  describe "GET #new" do
    it "returns a success response" do
      get :new, params: { category_id: category.to_param,
                          project_id: project.to_param,
                          task_id: task.to_param }
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    it "returns a success response" do
      task_comment = Fabricate(:task_comment, task: task)
      get :edit, params: { category_id: category.to_param,
                           project_id: project.to_param,
                           task_id: task.to_param,
                           id: task_comment.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    let(:url) do
      category_project_task_url(category, project, task,
                                anchor: "comment-#{TaskComment.last.id}")
    end

    context "with valid params" do
      it "creates a new TaskComment" do
        expect do
          post :create, params: { category_id: category.to_param,
                                  project_id: project.to_param,
                                  task_id: task.to_param,
                                  task_comment: valid_attributes }
        end.to change(TaskComment, :count).by(1)
      end

      it "redirects to the created task_comment" do
        post :create, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                task_id: task.to_param,
                                task_comment: valid_attributes }
        expect(response).to redirect_to(url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'new' template)" do
        post :create, params: { category_id: category.to_param,
                                project_id: project.to_param,
                                task_id: task.to_param,
                                task_comment: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PUT #update" do
    let(:url) do
    end

    context "with valid params" do
      let(:new_attributes) { { body: "New body" } }

      it "updates the requested task_comment" do
        task_comment = Fabricate(:task_comment, task: task)
        expect do
          put :update, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 task_id: task.to_param,
                                 id: task_comment.to_param,
                                 task_comment: new_attributes }
          task_comment.reload
        end.to change(task_comment, :body).to("New body")
      end

      it "redirects to the task_comment" do
        task_comment = Fabricate(:task_comment, task: task)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               task_id: task.to_param,
                               id: task_comment.to_param,
                               task_comment: new_attributes }
        url = category_project_task_url(category, project, task,
                                        anchor: "comment-#{task_comment.id}")
        expect(response).to redirect_to(url)
      end
    end

    context "with invalid params" do
      it "returns a success response (i.e. to display the 'edit' template)" do
        task_comment = Fabricate(:task_comment, task: task)
        put :update, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               task_id: task.to_param,
                               id: task_comment.to_param,
                               task_comment: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested task_comment" do
      task_comment = Fabricate(:task_comment, task: task)
      expect do
        delete :destroy, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   task_id: task.to_param,
                                   id: task_comment.to_param }
      end.to change(TaskComment, :count).by(-1)
    end

    it "redirects to the task_comments list" do
      task_comment = Fabricate(:task_comment, task: task)
      delete :destroy, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 task_id: task.to_param,
                                 id: task_comment.to_param }
      expect(response)
        .to redirect_to(category_project_task_url(category, project, task))
    end
  end
end
