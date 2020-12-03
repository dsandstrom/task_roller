# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:user_worker) { Fabricate(:user_worker) }

  let(:valid_attributes) do
    { assignee_ids: [user_worker.id] }
  end

  let(:blank_attributes) do
    { "assignee_ids[]" => nil }
  end

  describe "GET #index" do
    let(:user) { Fabricate(:user_worker) }
    let(:task) { Fabricate(:task) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when requesting another user" do
          before { task.assignees << user }

          it "returns a success response" do
            get :index, params: { user_id: user.to_param }
            expect(response).to be_successful
          end
        end

        context "when requesting themself" do
          before { task.assignees << current_user }

          it "returns a success response" do
            get :index, params: { user_id: current_user.to_param }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #edit" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          it "returns a success response" do
            task = Fabricate(:task, project: project)
            get :edit, params: { id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }

          it "returns a success response" do
            task = Fabricate(:task, project: project)
            get :edit, params: { id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when task category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          it "returns a success response" do
            task = Fabricate(:task, project: project)
            get :edit, params: { id: task.to_param }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          it "returns a success response" do
            task = Fabricate(:task, project: project)
            get :edit, params: { id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            get :edit, params: { id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when task category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            get :edit, params: { id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          task = Fabricate(:task, project: project)
          get :edit, params: { id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #update" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          context "with valid params" do
            it "updates the requested task's assignments" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(task, :assignee_ids)
            end

            it "subscribes the assignees" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(user_worker.task_subscriptions, :count).by(1)
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project)
              url = task_path(task)
              put :update, params: { id: task.to_param,
                                     task: valid_attributes }
              expect(response).to redirect_to(url)
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
                put :update, params: { id: task.to_param,
                                       task: blank_attributes }
                task.reload
              end.to change(task, :assignee_ids).to([])
            end

            it "doesn't change task_subscriptions" do
              expect do
                put :update, params: { id: task.to_param,
                                       task: blank_attributes }
              end.not_to change(TaskSubscription, :count)
            end

            it "redirects to the task" do
              url = task_path(task)
              put :update, params: { id: task.to_param,
                                     task: blank_attributes }
              expect(response).to redirect_to(url)
            end
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }

          context "with valid params" do
            it "updates the requested task's assignments" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(task, :assignee_ids)
            end

            it "subscribes the assignees" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(user_worker.task_subscriptions, :count).by(1)
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project)
              url = task_path(task)
              put :update, params: { id: task.to_param,
                                     task: valid_attributes }
              expect(response).to redirect_to(url)
            end
          end
        end

        context "when task category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          context "with valid params" do
            it "updates the requested task's assignments" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(task, :assignee_ids)
            end

            it "subscribes the assignees" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(user_worker.task_subscriptions, :count).by(1)
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project)
              url = task_path(task)
              put :update, params: { id: task.to_param,
                                     task: valid_attributes }
              expect(response).to redirect_to(url)
            end
          end
        end
      end
    end

    %w[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          context "with valid params" do
            it "updates the requested task's assignments" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(task, :assignee_ids)
            end

            it "subscribes the assignees" do
              task = Fabricate(:task, project: project)
              expect do
                put :update, params: { id: task.to_param,
                                       task: valid_attributes }
                task.reload
              end.to change(user_worker.task_subscriptions, :count).by(1)
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project)
              url = task_path(task)
              put :update, params: { id: task.to_param,
                                     task: valid_attributes }
              expect(response).to redirect_to(url)
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
                put :update, params: { id: task.to_param,
                                       task: blank_attributes }
                task.reload
              end.to change(task, :assignee_ids).to([])
            end

            it "doesn't change task_subscriptions" do
              expect do
                put :update, params: { id: task.to_param,
                                       task: blank_attributes }
              end.not_to change(TaskSubscription, :count)
            end

            it "redirects to the task" do
              url = task_path(task)
              put :update, params: { id: task.to_param,
                                     task: blank_attributes }
              expect(response).to redirect_to(url)
            end
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }

          it "doesn't update the requested task's assignments" do
            task = Fabricate(:task, project: project)
            expect do
              put :update, params: { id: task.to_param, task: valid_attributes }
              task.reload
            end.not_to change(task, :assignee_ids)
          end

          it "doesn't create any task_subscriptions" do
            task = Fabricate(:task, project: project)
            expect do
              put :update, params: { id: task.to_param, task: valid_attributes }
            end.not_to change(TaskSubscription, :count)
          end

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            put :update, params: { id: task.to_param, task: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end

        context "when task category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          it "doesn't update the requested task's assignments" do
            task = Fabricate(:task, project: project)
            expect do
              put :update, params: { id: task.to_param, task: valid_attributes }
              task.reload
            end.not_to change(task, :assignee_ids)
          end

          it "doesn't create any task_subscriptions" do
            task = Fabricate(:task, project: project)
            expect do
              put :update, params: { id: task.to_param, task: valid_attributes }
            end.not_to change(TaskSubscription, :count)
          end

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            put :update, params: { id: task.to_param, task: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't update the requested task's assignments" do
          task = Fabricate(:task, project: project)
          expect do
            put :update, params: { id: task.to_param, task: valid_attributes }
            task.reload
          end.not_to change(task, :assignee_ids)
        end

        it "doesn't create any task_subscriptions" do
          task = Fabricate(:task, project: project)
          expect do
            put :update, params: { id: task.to_param, task: valid_attributes }
          end.not_to change(TaskSubscription, :count)
        end

        it "should be unauthorized" do
          task = Fabricate(:task, project: project)
          put :update, params: { id: task.to_param, task: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
