# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskReopeningsController, type: :controller do
  let(:task) { Fabricate(:closed_task) }
  let(:current_user) { Fabricate(:user_reporter) }
  let(:subscriber) { Fabricate(:user_reporter) }

  describe "GET #new" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { task_id: task.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          get :new, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "with valid params" do
          it "creates a new TaskReopening for the task" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.to change(task.reopenings, :count).by(1)
          end

          it "creates a new TaskSubscription for the current_user" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.to change(current_user.task_subscriptions, :count).by(1)
          end

          it "opens the task" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.to change(task, :closed).to(false)
          end

          it "changes the requested task's status" do
            expect do
              post :create, params: { task_id: task.to_param }
              task.reload
            end.to change(task, :status).to("open")
          end

          it "sends email to subscribers" do
            task.subscribers << current_user
            task.subscribers << subscriber
            expect do
              post :create, params: { task_id: task.to_param }
            end.to have_enqueued_job.on_queue("mailers")
          end

          it "redirects to the created task_reopening" do
            post :create, params: { task_id: task.to_param }
            expect(response).to redirect_to(task)
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't create a new TaskReopening" do
          expect do
            post :create, params: { task_id: task.to_param }
          end.not_to change(TaskReopening, :count)
        end

        it "doesn't create a new TaskSubscription" do
          expect do
            post :create, params: { task_id: task.to_param }
          end.not_to change(TaskSubscription, :count)
        end

        it "doesn't open the task" do
          expect do
            post :create, params: { task_id: task.to_param }
            task.reload
          end.not_to change(task, :closed).from(true)
        end

        it "should be unauthorized" do
          post :create, params: { task_id: task.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let(:task) { Fabricate(:open_task) }

    %w[admin].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "destroys the requested task_reopening" do
          task_reopening = Fabricate(:task_reopening, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_reopening.to_param }
          end.to change(TaskReopening, :count).by(-1)
        end

        it "doesn't change the requested task_reopening's task" do
          task_reopening = Fabricate(:task_reopening, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_reopening.to_param }
          end.not_to change(task, :closed)
        end

        it "redirects to the task_reopenings list" do
          task_reopening = Fabricate(:task_reopening, task: task)
          delete :destroy, params: { task_id: task.to_param,
                                     id: task_reopening.to_param }
          expect(response).to redirect_to(task)
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't destroy the requested task_reopening" do
          task_reopening = Fabricate(:task_reopening, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_reopening.to_param }
          end.not_to change(TaskReopening, :count)
        end

        it "doesn't change the requested task_reopening's task" do
          task_reopening = Fabricate(:task_reopening, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_reopening.to_param }
          end.not_to change(task, :closed)
        end

        it "should be unauthorized" do
          task_reopening = Fabricate(:task_reopening, task: task)
          delete :destroy, params: { task_id: task.to_param,
                                     id: task_reopening.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
