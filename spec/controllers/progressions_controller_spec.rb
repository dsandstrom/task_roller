# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgressionsController, type: :controller do
  let(:task) { Fabricate(:task) }

  describe "GET #new" do
    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when progression task is assigned to them" do
          before { task.assignees << current_user }

          it "returns a success response" do
            get :new, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when progression task is not assigned to them" do
          it "should be unauthorized" do
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when progression task is assigned to them" do
          before { task.assignees << current_user }

          it "should be unauthorized" do
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when progression task is not assigned to them" do
          it "should be unauthorized" do
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:path) { task_path(task) }

    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when progression task is assigned to them" do
          before { task.assignees << current_user }

          context "with valid params" do
            it "creates a new Progression for the user" do
              expect do
                post :create, params: { task_id: task.to_param }
              end.to change(current_user.progressions, :count).by(1)
            end

            it "creates a new Progression for the task" do
              expect do
                post :create, params: { task_id: task.to_param }
              end.to change(task.progressions, :count).by(1)
            end

            it "changes the task status" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(task, :status).to("in_progress")
            end

            it "redirects to the task" do
              post :create, params: { task_id: task.to_param }
              expect(response).to redirect_to(path)
            end
          end
        end

        context "when progression task is not assigned to them" do
          it "doesn't create a new Progression" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(Progression, :count)
          end

          it "should be unauthorized" do
            post :create, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when progression task is assigned to them" do
          before { task.assignees << current_user }

          it "doesn't create a new Progression" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(Progression, :count)
          end

          it "should be unauthorized" do
            post :create, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when progression task is not assigned to them" do
          it "doesn't create a new Progression" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(Progression, :count)
          end

          it "should be unauthorized" do
            post :create, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "PUT #finish" do
    let(:new_user) { Fabricate(:user_worker) }
    let(:task) { Fabricate(:open_task, status: "in_progress") }
    let(:path) { task_path(task) }

    %w[admin reviewer worker].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before do
          task.assignees << current_user
          sign_in(current_user)
        end

        context "when their progression" do
          context "with valid params" do
            it "updates the requested progression" do
              progression =
                Fabricate(:progression, task: task, user: current_user)
              expect do
                patch :finish, params: { task_id: task.to_param,
                                         id: progression.to_param }
                progression.reload
              end.to change(progression, :finished).to(true)
            end

            it "doesn't change the requested task's status" do
              progression =
                Fabricate(:progression, task: task, user: current_user)
              expect do
                patch :finish, params: { task_id: task.to_param,
                                         id: progression.to_param }
                task.reload
              end.not_to change(task, :status)
            end

            it "redirects to the task" do
              progression =
                Fabricate(:progression, task: task, user: current_user)
              patch :finish, params: { task_id: task.to_param,
                                       id: progression.to_param }
              expect(response).to redirect_to(path)
            end
          end

          context "with invalid params" do
            let(:progression) do
              Fabricate(:progression, task: task, user: current_user)
            end

            before do
              # make previous progression invalid
              invalid = Fabricate(:progression, task: progression.task)
              invalid.update_columns finished: false, finished_at: nil,
                                     user_id: current_user.id
            end

            it "doesn't update the requested progression" do
              expect do
                patch :finish, params: { task_id: task.to_param,
                                         id: progression.to_param }
                progression.reload
              end.not_to change(progression, :finished)
            end

            it "returns a success response ('edit' template)" do
              patch :finish, params: { task_id: task.to_param,
                                       id: progression.to_param }
              expect(response).to be_successful
            end
          end
        end

        context "when someone else's progression" do
          it "doesn't update the requested progression" do
            progression = Fabricate(:progression, task: task)
            expect do
              patch :finish, params: { task_id: task.to_param,
                                       id: progression.to_param }
              progression.reload
            end.not_to change(progression, :finished)
          end

          it "should be unauthorized" do
            progression = Fabricate(:progression, task: task)
            patch :finish, params: { task_id: task.to_param,
                                     id: progression.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before do
          task.assignees << current_user
          sign_in(current_user)
        end

        context "when their progression" do
          it "doesn't update the requested progression" do
            progression = Fabricate(:progression, task: task,
                                                  user: current_user)
            expect do
              patch :finish, params: { task_id: task.to_param,
                                       id: progression.to_param }
              progression.reload
            end.not_to change(progression, :finished)
          end

          it "should be unauthorized" do
            progression = Fabricate(:progression, task: task,
                                                  user: current_user)
            patch :finish, params: { task_id: task.to_param,
                                     id: progression.to_param }
            expect_to_be_unauthorized(response)
          end
        end

        context "when someone else's progression" do
          it "doesn't update the requested progression" do
            progression = Fabricate(:progression, task: task)
            expect do
              patch :finish, params: { task_id: task.to_param,
                                       id: progression.to_param }
              progression.reload
            end.not_to change(progression, :finished)
          end

          it "should be unauthorized" do
            progression = Fabricate(:progression, task: task)
            patch :finish, params: { task_id: task.to_param,
                                     id: progression.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:task) { Fabricate(:open_task, status: "in_progress") }
    let(:path) { task_path(task) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "destroys the requested progression" do
          progression = Fabricate(:progression, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: progression.to_param }
          end.to change(Progression, :count).by(-1)
        end

        it "updates the requested task" do
          progression = Fabricate(:progression, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: progression.to_param }
            task.reload
          end.to change(task, :status).to("open")
        end

        it "redirects to task" do
          progression = Fabricate(:progression, task: task)
          delete :destroy, params: { task_id: task.to_param,
                                     id: progression.to_param }
          expect(response).to redirect_to(path)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before do
          task.assignees << current_user
          sign_in(current_user)
        end

        it "doesn't destroy the requested progression" do
          progression = Fabricate(:progression, task: task, user: current_user)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: progression.to_param }
          end.not_to change(Progression, :count)
        end

        it "should be unauthorized" do
          progression = Fabricate(:progression, task: task, user: current_user)
          delete :destroy, params: { task_id: task.to_param,
                                     id: progression.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
