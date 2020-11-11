# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskClosuresController, type: :controller do
  let(:task) { Fabricate(:open_task) }

  describe "GET #new" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "returns a success response" do
          get :new, params: { task_id: task.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when their own task" do
          let(:task) { Fabricate(:open_task, user: current_user) }

          it "returns a success response" do
            get :new, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when someone else's task" do
          let(:task) { Fabricate(:open_task) }

          it "should be unauthorized" do
            get :new, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "should be unauthorized" do
          get :new, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "with valid params" do
          it "creates a new TaskClosure for the task" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.to change(task.closures, :count).by(1)
          end

          it "creates a new TaskSubscription for the current_user" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.to change(current_user.task_subscriptions, :count).by(1)
          end

          it "closes the task" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.to change(task, :closed).to(true)
          end

          it "redirects to the created task_closure" do
            post :create, params: { task_id: task.to_param }
            expect(response).to redirect_to(task)
          end
        end
      end
    end

    %w[reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "when their own task" do
          let(:task) { Fabricate(:open_task, user: current_user) }

          context "with valid params" do
            it "creates a new TaskClosure for the task" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(task.closures, :count).by(1)
            end

            it "creates a new TaskSubscription for the current_user" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(current_user.task_subscriptions, :count).by(1)
            end

            it "closes the task" do
              expect do
                post :create, params: { task_id: task.to_param }
                task.reload
              end.to change(task, :closed).to(true)
            end

            it "redirects to the created task_closure" do
              post :create, params: { task_id: task.to_param }
              expect(response).to redirect_to(task)
            end
          end
        end

        context "when someone else's task" do
          let(:task) { Fabricate(:open_task) }

          it "doesn't create a new TaskClosure" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(TaskClosure, :count)
          end

          it "doesn't create a new TaskSubscription" do
            expect do
              post :create, params: { task_id: task.to_param }
            end.not_to change(TaskSubscription, :count)
          end

          it "doesn't close the task" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.not_to change(task, :closed).from(false)
          end

          it "should be unauthorized" do
            post :create, params: { task_id: task.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't create a new TaskClosure" do
          expect do
            post :create, params: { task_id: task.to_param }
          end.not_to change(TaskClosure, :count)
        end

        it "doesn't create a new TaskSubscription" do
          expect do
            post :create, params: { task_id: task.to_param }
          end.not_to change(TaskSubscription, :count)
        end

        it "doesn't close the task" do
          expect do
            post :create, params: { task_id: task.to_param }
            task.reload
          end.not_to change(task, :closed).from(false)
        end

        it "should be unauthorized" do
          post :create, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:task) { Fabricate(:closed_task) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "destroys the requested task_closure" do
          task_closure = Fabricate(:task_closure, task: task)
          expect do
            delete :destroy, params: { id: task_closure.to_param }
          end.to change(TaskClosure, :count).by(-1)
        end

        it "doesn't change the requested task_closure's task" do
          task_closure = Fabricate(:task_closure, task: task)
          expect do
            delete :destroy, params: { id: task_closure.to_param }
          end.not_to change(task, :closed)
        end

        it "redirects to the task_closures list" do
          task_closure = Fabricate(:task_closure, task: task)
          delete :destroy, params: { id: task_closure.to_param }
          expect(response).to redirect_to(task)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested task_closure" do
          task_closure = Fabricate(:task_closure, task: task)
          expect do
            delete :destroy, params: { id: task_closure.to_param }
          end.not_to change(TaskClosure, :count)
        end

        it "doesn't change the requested task_closure's task" do
          task_closure = Fabricate(:task_closure, task: task)
          expect do
            delete :destroy, params: { id: task_closure.to_param }
          end.not_to change(task, :closed)
        end

        it "should be unauthorized" do
          task_closure = Fabricate(:task_closure, task: task)
          delete :destroy, params: { id: task_closure.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
