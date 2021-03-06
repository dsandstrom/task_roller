# frozen_string_literal: true

require "rails_helper"

RSpec.describe TaskCommentsController, type: :controller do
  let(:category) { Fabricate(:category) }
  let(:project) { Fabricate(:project, category: category) }
  let(:task) { Fabricate(:task, project: project) }
  let(:admin) { Fabricate(:user_admin) }

  let(:valid_attributes) { { body: "Body" } }
  let(:invalid_attributes) { { body: "" } }

  describe "GET #new" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when html request" do
          it "returns a success response" do
            get :new, params: { task_id: task.to_param }
            expect(response).to be_successful
          end
        end

        context "when js request" do
          it "returns a success response" do
            get :new, params: { task_id: task.to_param }, xhr: true
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #show" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when html request" do
          it "returns a success response" do
            task_comment = Fabricate(:task_comment, task: task)
            url = task_url(task, anchor: "comment-#{task_comment.id}")
            get :show, params: { task_id: task.to_param,
                                 id: task_comment.to_param }
            expect(response).to redirect_to(url)
          end
        end

        context "when js request" do
          it "returns a success response" do
            task_comment = Fabricate(:task_comment, task: task)
            get :show, params: { task_id: task.to_param,
                                 id: task_comment.to_param },
                       xhr: true
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { sign_in(admin) }

      context "for their own TaskComment" do
        context "when html request" do
          it "returns a success response" do
            task_comment = Fabricate(:task_comment, task: task, user: admin)
            get :edit, params: { task_id: task.to_param,
                                 id: task_comment.to_param }
            expect(response).to be_successful
          end
        end

        context "when js request" do
          it "returns a success response" do
            task_comment = Fabricate(:task_comment, task: task, user: admin)
            get :edit, params: { task_id: task.to_param,
                                 id: task_comment.to_param }, xhr: true
            expect(response).to be_successful
          end
        end
      end

      context "for someone else's TaskComment" do
        it "returns a success response" do
          task_comment = Fabricate(:task_comment, task: task)
          get :edit, params: { task_id: task.to_param,
                               id: task_comment.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "for their own TaskComment" do
          it "returns a success response" do
            task_comment =
              Fabricate(:task_comment, task: task, user: current_user)
            get :edit, params: { task_id: task.to_param,
                                 id: task_comment.to_param }
            expect(response).to be_successful
          end
        end

        context "for someone else's TaskComment" do
          it "should be unauthorized" do
            task_comment = Fabricate(:task_comment, task: task)
            get :edit, params: { task_id: task.to_param,
                                 id: task_comment.to_param }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "POST #create" do
    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "with valid params" do
          it "creates a new TaskComment" do
            expect do
              post :create, params: { task_id: task.to_param,
                                      task_comment: valid_attributes }
            end.to change(current_user.task_comments, :count).by(1)
          end

          it "redirects to the created task_comment" do
            post :create, params: { task_id: task.to_param,
                                    task_comment: valid_attributes }
            anchor = "comment-#{TaskComment.last.id}"
            url = task_url(task, anchor: anchor)
            expect(response).to redirect_to(url)
          end

          context "when already subscribed to the task" do
            before do
              Fabricate(:task_subscription, task: task, user: current_user)
            end

            it "doesn't create a new TaskSubscription" do
              expect do
                post :create, params: { task_id: task.to_param,
                                        task_comment: valid_attributes }
              end.not_to change(TaskSubscription, :count)
            end

            it "doesn't send an email" do
              expect do
                post :create, params: { task_id: task.to_param,
                                        task_comment: valid_attributes }
              end.not_to have_enqueued_job
            end
          end

          context "when not already subscribed to the task" do
            before { current_user.task_subscriptions.destroy_all }

            it "creates a new TaskSubscription" do
              expect do
                post :create, params: { task_id: task.to_param,
                                        task_comment: valid_attributes }
              end.to change(current_user.task_subscriptions, :count).by(1)
            end
          end

          context "when someone else subscribed to task" do
            let(:user_reporter) { Fabricate(:user_reporter) }

            before do
              Fabricate(:task_subscription, task: task, user: user_reporter)
            end

            it "sends an email" do
              expect do
                post :create, params: { task_id: task.to_param,
                                        task_comment: valid_attributes }
              end.to(have_enqueued_job.with do |mailer, action, time, options|
                expect(mailer).to eq("TaskMailer")
                expect(action).to eq("comment")
                expect(time).to eq("deliver_now")
                expect(options)
                  .to eq(args: [], params: { task: task, user: user_reporter,
                                             comment: TaskComment.last })
              end)
            end
          end
        end

        context "with invalid params" do
          it "returns a success response ('new' template)" do
            post :create, params: { task_id: task.to_param,
                                    task_comment: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { body: "New body" } }

    context "for an admin" do
      before { sign_in(admin) }

      context "for their own TaskComment" do
        context "with valid params" do
          context "when html request" do
            it "updates the requested task_comment" do
              task_comment = Fabricate(:task_comment, task: task, user: admin)
              expect do
                put :update, params: { task_id: task.to_param,
                                       id: task_comment.to_param,
                                       task_comment: new_attributes }
                task_comment.reload
              end.to change(task_comment, :body).to("New body")
            end

            it "redirects to the task_comment" do
              task_comment = Fabricate(:task_comment, task: task, user: admin)
              url =
                task_url(task, anchor: "comment-#{task_comment.id}")
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              expect(response).to redirect_to(url)
            end
          end

          context "when js request" do
            it "updates the requested task_comment" do
              task_comment = Fabricate(:task_comment, task: task, user: admin)
              expect do
                put :update, params: { task_id: task.to_param,
                                       id: task_comment.to_param,
                                       task_comment: new_attributes }, xhr: true
                task_comment.reload
              end.to change(task_comment, :body).to("New body")
            end

            it "redirects to the task_comment" do
              task_comment = Fabricate(:task_comment, task: task, user: admin)
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }, xhr: true
              expect(response).to be_successful
            end
          end
        end

        context "with invalid params" do
          context "when html request" do
            it "returns a success response ('edit' template)" do
              task_comment = Fabricate(:task_comment, task: task, user: admin)
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: invalid_attributes }
              expect(response).to be_successful
            end
          end

          context "when js request" do
            it "returns a success response ('edit' template)" do
              task_comment = Fabricate(:task_comment, task: task, user: admin)
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: invalid_attributes },
                           xhr: true
              expect(response).to be_successful
            end
          end
        end
      end

      context "for someone else's TaskComment" do
        context "with valid params" do
          let(:new_attributes) { { body: "New body" } }

          it "updates the requested task_comment" do
            task_comment = Fabricate(:task_comment, task: task)
            expect do
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              task_comment.reload
            end.to change(task_comment, :body).to("New body")
          end

          it "redirects to the task_comment" do
            task_comment = Fabricate(:task_comment, task: task)
            url =
              task_url(task, anchor: "comment-#{task_comment.id}")
            put :update, params: { task_id: task.to_param,
                                   id: task_comment.to_param,
                                   task_comment: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            task_comment = Fabricate(:task_comment, task: task)
            put :update, params: { task_id: task.to_param,
                                   id: task_comment.to_param,
                                   task_comment: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "for their own TaskComment" do
          context "with valid params" do
            it "updates the requested task_comment" do
              task_comment =
                Fabricate(:task_comment, task: task, user: current_user)
              expect do
                put :update, params: { task_id: task.to_param,
                                       id: task_comment.to_param,
                                       task_comment: new_attributes }
                task_comment.reload
              end.to change(task_comment, :body).to("New body")
            end

            it "redirects to the task_comment" do
              task_comment = Fabricate(:task_comment, task: task,
                                                      user: current_user)
              anchor = "comment-#{task_comment.id}"
              url = task_url(task, anchor: anchor)
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              task_comment =
                Fabricate(:task_comment, task: task, user: current_user)
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "for someone else's TaskComment" do
          context "when html request" do
            it "doesn't update the requested task_comment" do
              task_comment = Fabricate(:task_comment, task: task)
              expect do
                put :update, params: { task_id: task.to_param,
                                       id: task_comment.to_param,
                                       task_comment: new_attributes }
                task_comment.reload
              end.not_to change(task_comment, :body)
            end

            it "should be unauthorized" do
              task_comment = Fabricate(:task_comment, task: task)
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              expect_to_be_unauthorized(response)
            end
          end

          context "when js request" do
            it "doesn't update the requested task_comment" do
              task_comment = Fabricate(:task_comment, task: task)
              expect do
                put :update, params: { task_id: task.to_param,
                                       id: task_comment.to_param,
                                       task_comment: new_attributes },
                             xhr: true
                task_comment.reload
              end.not_to change(task_comment, :body)
            end

            it "should be unauthorized" do
              task_comment = Fabricate(:task_comment, task: task)
              put :update, params: { task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes },
                           xhr: true
              expect(response).to have_http_status(403)
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      before { sign_in(admin) }

      it "destroys the requested task_comment" do
        task_comment = Fabricate(:task_comment, task: task)
        expect do
          delete :destroy, params: { task_id: task.to_param,
                                     id: task_comment.to_param }
        end.to change(TaskComment, :count).by(-1)
      end

      it "redirects to the task_comments list" do
        task_comment = Fabricate(:task_comment, task: task)
        delete :destroy, params: { task_id: task.to_param,
                                   id: task_comment.to_param }
        expect(response).to redirect_to(task_url(task))
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        it "doesn't destroy the requested task_comment" do
          task_comment = Fabricate(:task_comment, task: task)
          expect do
            delete :destroy, params: { task_id: task.to_param,
                                       id: task_comment.to_param }
          end.not_to change(TaskComment, :count)
        end

        it "should be unauthorized" do
          task_comment = Fabricate(:task_comment, task: task)
          delete :destroy, params: { task_id: task.to_param,
                                     id: task_comment.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
