# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskAssigneesController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:user_worker) { Fabricate(:user_worker) }

  describe "GET #new" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          it "returns a success response" do
            task = Fabricate(:task, project: project)
            get :new, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when task category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          it "returns a success response" do
            task = Fabricate(:task, project: project)
            get :new, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when task category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          task = Fabricate(:task, project: project)
          get :new, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #create" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          context "with valid params" do
            it "assigns the current user to the requested task" do
              task = Fabricate(:task, project: project)
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(current_user.task_assignees, :count).by(1)
            end

            it "subscribes the current_user to the requested task" do
              task = Fabricate(:task, project: project)
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(current_user.task_assignees, :count).by(1)
            end

            it "updates the requested task's status" do
              task = Fabricate(:task, project: project)
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(task, :status).to("assigned")
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project)
              url = task_path(task)
              post :create, params: { task_id: task.to_param }
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            let(:task) { Fabricate(:task, project: project) }

            before do
              Fabricate(:task_assignee, task: task, assignee: current_user)
            end

            it "doesn't assign the current user to the requested task" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.not_to change(current_user.task_assignees, :count)
            end

            it "doesn't subscribe the current_user" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.not_to change(current_user.task_assignees, :count)
            end

            it "should be unauthorized" do
              post :create, params: { task_id: task.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }
          let(:task) { Fabricate(:task, project: project) }

          context "with valid params" do
            it "doesn't assign the current user to the requested task" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.not_to change(current_user.task_assignees, :count)
            end

            it "doesn't subscribe the current_user" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.not_to change(current_user.task_assignees, :count)
            end

            it "should be unauthorized" do
              post :create, params: { task_id: task.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end
      end
    end

    %w[reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when task category/project are visible" do
          context "with valid params" do
            it "assigns the current user to the requested task" do
              task = Fabricate(:task, project: project)
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(current_user.task_assignees, :count).by(1)
            end

            it "subscribes the current_user to the requested task" do
              task = Fabricate(:task, project: project)
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(current_user.task_assignees, :count).by(1)
            end

            it "redirects to the task" do
              task = Fabricate(:task, project: project)
              url = task_path(task)
              post :create, params: { task_id: task.to_param }
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            let(:task) { Fabricate(:task, project: project) }

            before do
              Fabricate(:task_assignee, task: task, assignee: current_user)
            end

            it "doesn't assign the current user to the requested task" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.not_to change(current_user.task_assignees, :count)
            end

            it "doesn't subscribe the current_user" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.not_to change(current_user.task_assignees, :count)
            end

            it "should be unauthorized" do
              post :create, params: { task_id: task.to_param }
              expect_to_be_unauthorized(response)
            end
          end
        end

        context "when task project is invisible" do
          let(:project) { Fabricate(:invisible_project) }

          it "doesn't update the requested task's assignments" do
            task = Fabricate(:task, project: project)
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.not_to change(task, :assignee_ids)
          end

          it "doesn't create any task_assignees" do
            task = Fabricate(:task, project: project)
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(TaskAssignee, :count)
          end

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            post :create, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when task category is invisible" do
          let(:category) { Fabricate(:invisible_category) }
          let(:project) { Fabricate(:project, category: category) }

          it "doesn't update the requested task's assignments" do
            task = Fabricate(:task, project: project)
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.not_to change(task, :assignee_ids)
          end

          it "doesn't create any task_assignees" do
            task = Fabricate(:task, project: project)
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(TaskAssignee, :count)
          end

          it "should be unauthorized" do
            task = Fabricate(:task, project: project)
            post :create, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't update the requested task's assignments" do
          task = Fabricate(:task, project: project)
          expect do
            post :create, params: { task_id: task.to_param }
            task.reload
          end.not_to change(task, :assignee_ids)
        end

        it "doesn't create any task_assignees" do
          task = Fabricate(:task, project: project)
          expect do
            post :create, params: { task_id: task.to_param }
          end.not_to change(TaskAssignee, :count)
        end

        it "should be unauthorized" do
          task = Fabricate(:task, project: project)
          post :create, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:task) { Fabricate(:task, status: "assigned") }

    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when their task_assignee" do
          it "destroys the requested task_assignee" do
            task_assignee =
              Fabricate(:task_assignee, task: task, assignee: current_user)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_assignee.to_param }
            end.to change(current_user.task_assignees, :count).by(-1)
          end

          it "changes the requested task's status" do
            task_assignee =
              Fabricate(:task_assignee, task: task, assignee: current_user)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_assignee.to_param }
              task.reload
            end.to change(task, :status).to("open")
          end

          it "finishes requested task's progressions" do
            task_assignee =
              Fabricate(:task_assignee, task: task, assignee: current_user)
            progression =
              Fabricate(:unfinished_progression, task: task, user: current_user)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_assignee.to_param }
              progression.reload
            end.to change(progression, :finished).to(true)
          end

          it "doesn't finish different task progressions" do
            task_assignee =
              Fabricate(:task_assignee, task: task, assignee: current_user)
            progression = Fabricate(:unfinished_progression, user: current_user)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_assignee.to_param }
              progression.reload
            end.not_to change(progression, :finished)
          end

          it "redirects to the task_assignees list" do
            task_assignee =
              Fabricate(:task_assignee, task: task, assignee: current_user)
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_assignee.to_param }
            expect(response).to redirect_to(task)
          end
        end

        context "when someone else's task_assignee" do
          it "doesn't destroys the requested task_assignee" do
            task_assignee = Fabricate(:task_assignee, task: task)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_assignee.to_param }
            end.not_to change(TaskAssignee, :count)
          end

          it "should be unauthorized" do
            task_assignee = Fabricate(:task_assignee, task: task)
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_assignee.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when their task_assignee" do
          it "doesn't destroys the requested task_assignee" do
            task_assignee = Fabricate(:task_assignee, task: task,
                                                      assignee: current_user)
            expect do
              delete :destroy, params: { task_id: task.to_param,
                                         id: task_assignee.to_param }
            end.not_to change(TaskAssignee, :count)
          end

          it "should be unauthorized" do
            task_assignee = Fabricate(:task_assignee, task: task,
                                                      assignee: current_user)
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_assignee.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end
end
