# frozen_string_literal: true

require "rails_helper"

RSpec.describe ProgressionsController, type: :controller do
  let(:task) { Fabricate(:task) }
  let(:worker) { Fabricate(:user_worker) }

  let(:valid_attributes) do
    { user_id: worker.id.to_s }
  end

  let(:invalid_attributes) do
    { user_id: "" }
  end

  describe "GET #index" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          _progression = Fabricate(:progression, task: task)
          get :index, params: { task_id: task.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

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
  end

  describe "GET #edit" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "returns a success response" do
          progression = Fabricate(:progression, task: task)
          get :edit, params: { task_id: task.to_param,
                               id: progression.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          task.assignees << current_user
          progression = Fabricate(:progression, task: task, user: current_user)
          get :edit, params: { task_id: task.to_param,
                               id: progression.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let(:path) { task_path(task) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { login(current_user) }

        context "when progression task is assigned to them" do
          before { task.assignees << current_user }

          context "with valid params" do
            it "creates a new Progression" do
              expect do
                post :create, params: { task_id: task.to_param }
              end.to change(current_user.progressions, :count).by(1)
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
              post :create, params: { task_id: task.to_param,
                                      progression: valid_attributes }
            end.not_to change(Progression, :count)
          end

          it "should be unauthorized" do
            post :create, params: { task_id: task.to_param,
                                    progression: valid_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_user) { Fabricate(:user_worker) }
    let(:path) { task_path(task) }
    let(:new_attributes) { { user_id: new_user.id.to_s } }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "with valid params" do
          it "updates the requested progression" do
            progression = Fabricate(:progression, task: task)
            expect do
              put :update, params: { task_id: task.to_param,
                                     id: progression.to_param,
                                     progression: new_attributes }
              progression.reload
            end.to change(progression, :user_id).to(new_user.id)
          end

          it "redirects to the task" do
            progression = Fabricate(:progression, task: task)
            put :update, params: { task_id: task.to_param,
                                   id: progression.to_param,
                                   progression: valid_attributes }
            expect(response).to redirect_to(path)
          end
        end

        context "with invalid params" do
          it "doesn't update the requested progression" do
            progression = Fabricate(:progression, task: task)
            expect do
              put :update, params: { task_id: task.to_param,
                                     id: progression.to_param,
                                     progression: invalid_attributes }
              progression.reload
            end.not_to change(progression, :user_id)
          end

          it "returns a success response ('edit' template)" do
            progression = Fabricate(:progression, task: task)
            put :update, params: { task_id: task.to_param,
                                   id: progression.to_param,
                                   progression: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before do
          task.assignees << current_user
          login(current_user)
        end

        it "doesn't update the requested progression" do
          progression = Fabricate(:progression, task: task, user: current_user)
          expect do
            put :update, params: { task_id: task.to_param,
                                   id: progression.to_param,
                                   progression: invalid_attributes }
            progression.reload
          end.not_to change(progression, :user_id)
        end

        it "should be unauthorized" do
          progression = Fabricate(:progression, task: task, user: current_user)
          put :update, params: { task_id: task.to_param,
                                 id: progression.to_param,
                                 progression: valid_attributes }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "PUT #finish" do
    let(:new_user) { Fabricate(:user_worker) }
    let(:path) { task_path(task) }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before do
          task.assignees << current_user
          login(current_user)
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
  end

  describe "DELETE #destroy" do
    let(:path) { task_path(task) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "destroys the requested progression" do
          progression = Fabricate(:progression, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: progression.to_param }
          end.to change(Progression, :count).by(-1)
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
          login(current_user)
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
