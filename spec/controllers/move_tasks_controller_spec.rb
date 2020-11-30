# frozen_string_literal: true

require "rails_helper"

RSpec.describe MoveTasksController, type: :controller do
  let(:new_project) { Fabricate(:project) }

  let(:valid_attributes) { { project_id: new_project.to_param } }
  let(:invalid_attributes) { { project_id: "" } }

  describe "GET #edit" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "returns a success response" do
          task = Fabricate(:task)
          get :edit, params: { task_id: task.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          task = Fabricate(:task)
          get :edit, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        context "with valid params" do
          it "updates the requested task" do
            task = Fabricate(:task)
            expect do
              put :update, params: { task_id: task.to_param,
                                     task: valid_attributes }
              task.reload
            end.to change(task, :project_id).to(new_project.id)
          end

          it "redirects to the task" do
            task = Fabricate(:task)
            put :update, params: { task_id: task.to_param,
                                   task: valid_attributes }
            expect(response).to redirect_to(task)
          end
        end

        context "with invalid params" do
          it "doesn't update the requested task" do
            task = Fabricate(:task)
            expect do
              put :update, params: { task_id: task.to_param,
                                     task: invalid_attributes }
              task.reload
            end.not_to change(task, :project_id)
          end

          it "redirects to edit" do
            task = Fabricate(:task)
            put :update, params: { task_id: task.to_param,
                                   task: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type}")) }

        it "redirects to unauthorized" do
          task = Fabricate(:task)
          put :update, params: { task_id: task.to_param,
                                 task: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
