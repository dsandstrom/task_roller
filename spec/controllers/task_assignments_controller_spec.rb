# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskAssignmentsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:user_worker) { Fabricate(:user_worker) }

  let(:valid_attributes) do
    { assignee_ids: [user_worker.id] }
  end

  let(:blank_attributes) do
    { "assignee_ids[]" => nil }
  end

  describe "GET #edit" do
    it "returns a success response" do
      task = Fabricate(:task, project: project)
      get :edit, params: { id: task.to_param }
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      it "updates the requested task's assignments" do
        task = Fabricate(:task, project: project)
        expect do
          put :update, params: { id: task.to_param, task: valid_attributes }
          task.reload
        end.to change(task, :assignee_ids)
      end

      it "redirects to the task" do
        task = Fabricate(:task, project: project)
        put :update, params: { id: task.to_param, task: valid_attributes }
        expect(response)
          .to redirect_to(category_project_task_path(category, project, task))
      end
    end

    context "with blank params" do
      let(:task) { Fabricate(:task, project: project) }

      before do
        task.update(valid_attributes)
        task.reload
      end

      it "updates the requested task's assignments" do
        expect do
          put :update, params: { id: task.to_param, task: blank_attributes }
          task.reload
        end.to change(task, :assignee_ids).to([])
      end

      it "redirects to the task" do
        put :update, params: { id: task.to_param, task: blank_attributes }
        expect(response)
          .to redirect_to(category_project_task_path(category, project, task))
      end
    end

    # TODO: add invalid test
    # context "with invalid params" do
    #   it "returns a success response (i.e. to display the 'edit' template)" do
    #     task = Fabricate(:task, project: project)
    #     put :update, params: { id: task.to_param, task: invalid_attributes }
    #     expect(response).to be_success
    #   end
    # end
  end
end