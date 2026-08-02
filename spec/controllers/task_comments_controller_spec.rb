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

        context "when turbo_stream request" do
          it "returns a success response" do
            get :new, params: { task_id: task.to_param }, as: :turbo_stream
            expect(response).to be_successful
          end
        end
      end
    end
  end

  describe "GET #show" do
    let!(:task_comment) { Fabricate(:task_comment, task: task) }
    let(:params) { { task_id: task.to_param, id: task_comment.to_param } }
    let(:url) { task_url(task, anchor: "comment-#{task_comment.id}") }

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        before { sign_in(Fabricate("user_#{employee_type.downcase}")) }

        context "when html request" do
          it "returns a success response" do
            get :show, params: params
            expect(response).to redirect_to(url)
          end
        end

        context "when turbo_stream request" do
          it "returns a success response" do
            get :show, params: params, as: :turbo_stream
            expect(response).to redirect_to(url)
          end
        end
      end
    end
  end

  describe "GET #edit" do
    let(:params) { { task_id: task.to_param, id: task_comment.to_param } }

    context "for an admin" do
      before { sign_in(admin) }

      context "for their own TaskComment" do
        let(:task_comment) { Fabricate(:task_comment, task: task, user: admin) }

        context "when html request" do
          it "returns a success response" do
            get :edit, params: params
            expect(response).to be_successful
          end
        end

        context "when js request" do
          it "returns a success response" do
            get :edit, params: params, as: :turbo_stream
            expect(response).to be_successful
          end
        end
      end

      context "for someone else's TaskComment" do
        let(:task_comment) { Fabricate(:task_comment, task: task) }

        context "when html request" do
          it "returns a success response" do
            get :edit, params: params
            expect(response).to be_successful
          end
        end

        context "when turbo_stream request" do
          it "returns a success response" do
            get :edit, params: params, as: :turbo_stream
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
          let(:task_comment) do
            Fabricate(:task_comment, task: task, user: current_user)
          end

          context "when html request" do
            it "returns a success response" do
              get :edit, params: params
              expect(response).to be_successful
            end
          end

          context "when turbo_stream request" do
            it "returns a success response" do
              get :edit, params: params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end

        context "for someone else's TaskComment" do
          let(:task_comment) { Fabricate(:task_comment, task: task) }

          context "when html request" do
            it "should be unauthorized" do
              get :edit, params: params
              expect_to_be_unauthorized(response)
            end
          end

          context "when turbo_stream request" do
            it "should be unauthorized" do
              get :edit, params: params, as: :turbo_stream
              expect(response).to have_http_status(403)
            end
          end
        end
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      { task_id: task.to_param, task_comment: valid_attributes }
    end

    let(:invalid_params) do
      { task_id: task.to_param, task_comment: invalid_attributes }
    end

    User::VALID_EMPLOYEE_TYPES.each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when html request" do
          context "with valid params" do
            context "when not subscribed to the task" do
              it "creates a new TaskComment" do
                expect do
                  post :create, params: valid_params
                end.to change(current_user.task_comments, :count).by(1)
              end

              it "redirects to the created task_comment" do
                post :create, params: valid_params
                url = task_url(task, anchor: "comment-#{TaskComment.last.id}")
                expect(response).to redirect_to(url)
              end
            end

            context "when already subscribed to the task" do
              before do
                Fabricate(:task_subscription, task: task, user: current_user)
              end

              it "doesn't create a new TaskSubscription" do
                expect do
                  post :create, params: valid_params
                end.not_to change(TaskSubscription, :count)
              end

              it "doesn't send an email" do
                expect do
                  post :create, params: valid_params
                end.not_to have_enqueued_job
              end
            end

            context "when someone else subscribed to task" do
              let(:user_reporter) { Fabricate(:user_reporter) }

              before do
                Fabricate(:task_subscription, task: task, user: user_reporter)
              end

              it "sends an email" do
                expect do
                  post :create, params: valid_params
                end.to(
                  have_enqueued_job.with do |mailer, action, time, options|
                    expect(mailer).to eq("TaskMailer")
                    expect(action).to eq("comment")
                    expect(time).to eq("deliver_now")
                    expect(options)
                      .to eq(
                        args: [],
                        params: { task: task, user: user_reporter,
                                  comment: TaskComment.last }
                      )
                  end
                )
              end
            end
          end

          context "with invalid params" do
            it "returns a success response ('new' template)" do
              post :create, params: invalid_params
              expect(response).to be_successful
            end
          end
        end

        context "when turbo_stream request" do
          context "with valid params" do
            context "when not subscribed to the task" do
              it "creates a new TaskComment" do
                expect do
                  post :create, params: valid_params, as: :turbo_stream
                end.to change(current_user.task_comments, :count).by(1)
              end

              it "redirects to the created task_comment" do
                post :create, params: valid_params, as: :turbo_stream
                expect(response).to be_successful
              end
            end

            context "when already subscribed to the task" do
              before do
                Fabricate(:task_subscription, task: task, user: current_user)
              end

              it "doesn't create a new TaskSubscription" do
                expect do
                  post :create, params: valid_params, as: :turbo_stream
                end.not_to change(TaskSubscription, :count)
              end

              it "doesn't send an email" do
                expect do
                  post :create, params: valid_params, as: :turbo_stream
                end.not_to have_enqueued_job
              end
            end

            context "when someone else subscribed to task" do
              let(:user_reporter) { Fabricate(:user_reporter) }

              before do
                Fabricate(:task_subscription, task: task, user: user_reporter)
              end

              it "sends an email" do
                expect do
                  post :create, params: valid_params, as: :turbo_stream
                end.to(
                  have_enqueued_job.with do |mailer, action, time, options|
                    expect(mailer).to eq("TaskMailer")
                    expect(action).to eq("comment")
                    expect(time).to eq("deliver_now")
                    expect(options)
                      .to eq(
                        args: [],
                        params: { task: task, user: user_reporter,
                                  comment: TaskComment.last }
                      )
                  end
                )
              end
            end
          end

          context "with invalid params" do
            it "returns a success response ('new' template)" do
              post :create, params: invalid_params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end
      end
    end
  end

  describe "PUT #update" do
    let(:new_attributes) { { body: "New body" } }

    let(:valid_params) do
      { task_id: task.to_param, id: task_comment.to_param,
        task_comment: new_attributes }
    end

    let(:invalid_params) do
      { task_id: task.to_param, id: task_comment.to_param,
        task_comment: invalid_attributes }
    end

    context "for an admin" do
      before { sign_in(admin) }

      context "for their own TaskComment" do
        let!(:task_comment) do
          Fabricate(:task_comment, task: task, user: admin)
        end

        let(:url) { task_url(task, anchor: "comment-#{task_comment.id}") }

        context "with valid params" do
          context "when html request" do
            it "updates the requested task_comment" do
              expect do
                put :update, params: valid_params
                task_comment.reload
              end.to change(task_comment, :body).to("New body")
            end

            it "redirects to the task" do
              put :update, params: valid_params
              expect(response).to redirect_to(url)
            end
          end

          context "when turbo_stream request" do
            it "updates the requested task_comment" do
              expect do
                put :update, params: valid_params, as: :turbo_stream
                task_comment.reload
              end.to change(task_comment, :body).to("New body")
            end

            it "redirects to the task" do
              put :update, params: valid_params, as: :turbo_stream
              expect(response).to redirect_to(url)
            end
          end
        end

        context "with invalid params" do
          context "when html request" do
            it "doesn't update the requested task_comment" do
              expect do
                put :update, params: invalid_params
                task_comment.reload
              end.not_to change(task_comment, :body)
            end

            it "returns a success response ('edit' template)" do
              put :update, params: invalid_params
              expect(response).to be_successful
            end
          end

          context "when turbo_stream request" do
            it "doesn't update the requested task_comment" do
              expect do
                put :update, params: invalid_params, as: :turbo_stream
                task_comment.reload
              end.not_to change(task_comment, :body)
            end

            it "returns a success response ('edit' template)" do
              put :update, params: invalid_params, as: :turbo_stream
              expect(response).to be_successful
            end
          end
        end
      end

      context "for someone else's TaskComment" do
        let!(:task_comment) { Fabricate(:task_comment, task: task) }
        let(:url) { task_url(task, anchor: "comment-#{task_comment.id}") }

        context "with valid params" do
          it "updates the requested task_comment" do
            expect do
              put :update, params: valid_params
              task_comment.reload
            end.to change(task_comment, :body).to("New body")
          end

          it "redirects to the task_comment" do
            put :update, params: valid_params
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "updates the requested task_comment" do
            expect do
              put :update, params: invalid_params
              task_comment.reload
            end.not_to change(task_comment, :body)
          end

          it "returns a success response ('edit' template)" do
            put :update, params: invalid_params
            expect(response).to be_successful
          end
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }
        let(:url) { task_url(task, anchor: "comment-#{task_comment.id}") }

        let!(:task_comment) do
          Fabricate(:task_comment, task: task, user: current_user)
        end

        before { sign_in(current_user) }

        context "for their own TaskComment" do
          context "when html request" do
            context "with valid params" do
              it "updates the requested task_comment" do
                expect do
                  put :update, params: valid_params
                  task_comment.reload
                end.to change(task_comment, :body).to("New body")
              end

              it "redirects to the task_comment" do
                put :update, params: valid_params
                expect(response).to redirect_to(url)
              end
            end

            context "with invalid params" do
              it "returns a success response ('edit' template)" do
                put :update, params: invalid_params
                expect(response).to be_successful
              end
            end
          end

          context "when turbo_stream request" do
            context "with valid params" do
              it "updates the requested task_comment" do
                expect do
                  put :update, params: valid_params, as: :turbo_stream
                  task_comment.reload
                end.to change(task_comment, :body).to("New body")
              end

              it "redirects to the task_comment" do
                put :update, params: valid_params, as: :turbo_stream
                expect(response).to redirect_to(url)
              end
            end

            context "with invalid params" do
              it "returns a success response ('edit' template)" do
                put :update, params: invalid_params, as: :turbo_stream
                expect(response).to be_successful
              end
            end
          end
        end

        context "for someone else's TaskComment" do
          let!(:task_comment) { Fabricate(:task_comment, task: task) }

          context "when html request" do
            it "doesn't update the requested task_comment" do
              expect do
                put :update, params: valid_params
                task_comment.reload
              end.not_to change(task_comment, :body)
            end

            it "should be unauthorized" do
              put :update, params: valid_params
              expect_to_be_unauthorized(response)
            end
          end

          context "when turbo_stream request" do
            it "doesn't update the requested task_comment" do
              expect do
                put :update, params: valid_params, as: :turbo_stream
                task_comment.reload
              end.not_to change(task_comment, :body)
            end

            it "should be unauthorized" do
              put :update, params: valid_params, as: :turbo_stream
              expect(response).to have_http_status(403)
            end
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:task_comment) { Fabricate(:task_comment, task: task) }
    let(:params) { { task_id: task.to_param, id: task_comment.to_param } }

    context "for an admin" do
      before { sign_in(admin) }

      context "when html request" do
        it "destroys the requested task_comment" do
          expect do
            delete :destroy, params: params
          end.to change(TaskComment, :count).by(-1)
        end

        it "redirects to the task_comments list" do
          delete :destroy, params: params
          expect(response).to redirect_to(task_url(task))
        end
      end

      context "when turbo_stream request" do
        it "destroys the requested task_comment" do
          expect do
            delete :destroy, params: params, as: :turbo_stream
          end.to change(TaskComment, :count).by(-1)
        end

        it "returns success" do
          delete :destroy, params: params, as: :turbo_stream
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { sign_in(current_user) }

        context "when html request" do
          it "doesn't destroy the requested task_comment" do
            expect do
              delete :destroy, params: params
            end.not_to change(TaskComment, :count)
          end

          it "should be unauthorized" do
            delete :destroy, params: params
            expect_to_be_unauthorized(response)
          end
        end

        context "when turbo_stream request" do
          it "doesn't destroy the requested task_comment" do
            expect do
              delete :destroy, params: params, as: :turbo_stream
            end.not_to change(TaskComment, :count)
          end

          it "should be unauthorized" do
            delete :destroy, params: params, as: :turbo_stream
            expect(response).to have_http_status(403)
          end
        end
      end
    end
  end
end
