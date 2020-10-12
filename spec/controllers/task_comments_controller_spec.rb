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
        before { login(Fabricate("user_#{employee_type.downcase}")) }

        it "returns a success response" do
          get :new, params: { category_id: category.to_param,
                              project_id: project.to_param,
                              task_id: task.to_param }
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET #edit" do
    context "for an admin" do
      before { login(admin) }

      context "for their own TaskComment" do
        it "returns a success response" do
          task_comment = Fabricate(:task_comment, task: task, user: admin)
          get :edit, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               task_id: task.to_param,
                               id: task_comment.to_param }
          expect(response).to be_successful
        end
      end

      context "for someone else's TaskComment" do
        it "returns a success response" do
          task_comment = Fabricate(:task_comment, task: task)
          get :edit, params: { category_id: category.to_param,
                               project_id: project.to_param,
                               task_id: task.to_param,
                               id: task_comment.to_param }
          expect(response).to be_successful
        end
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        context "for their own TaskComment" do
          it "returns a success response" do
            task_comment =
              Fabricate(:task_comment, task: task, user: current_user)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 task_id: task.to_param,
                                 id: task_comment.to_param }
            expect(response).to be_successful
          end
        end

        context "for someone else's TaskComment" do
          it "should be unauthorized" do
            task_comment = Fabricate(:task_comment, task: task)
            get :edit, params: { category_id: category.to_param,
                                 project_id: project.to_param,
                                 task_id: task.to_param,
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

        before { login(current_user) }

        context "with valid params" do
          it "creates a new TaskComment" do
            expect do
              post :create, params: { category_id: category.to_param,
                                      project_id: project.to_param,
                                      task_id: task.to_param,
                                      task_comment: valid_attributes }
            end.to change(current_user.task_comments, :count).by(1)
          end

          it "redirects to the created task_comment" do
            post :create, params: { category_id: category.to_param,
                                    project_id: project.to_param,
                                    task_id: task.to_param,
                                    task_comment: valid_attributes }
            anchor = "comment-#{TaskComment.last.id}"
            url = category_project_task_url(category, project, task,
                                            anchor: anchor)
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('new' template)" do
            post :create, params: { category_id: category.to_param,
                                    project_id: project.to_param,
                                    task_id: task.to_param,
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
      before { login(admin) }

      context "for their own TaskComment" do
        context "with valid params" do
          it "updates the requested task_comment" do
            task_comment = Fabricate(:task_comment, task: task, user: admin)
            expect do
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              task_comment.reload
            end.to change(task_comment, :body).to("New body")
          end

          it "redirects to the task_comment" do
            task_comment = Fabricate(:task_comment, task: task, user: admin)
            url =
              category_project_task_url(category, project, task,
                                        anchor: "comment-#{task_comment.id}")
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   task_id: task.to_param,
                                   id: task_comment.to_param,
                                   task_comment: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            task_comment = Fabricate(:task_comment, task: task, user: admin)
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   task_id: task.to_param,
                                   id: task_comment.to_param,
                                   task_comment: invalid_attributes }
            expect(response).to be_successful
          end
        end
      end

      context "for someone else's TaskComment" do
        context "with valid params" do
          let(:new_attributes) { { body: "New body" } }

          it "updates the requested task_comment" do
            task_comment = Fabricate(:task_comment, task: task)
            expect do
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              task_comment.reload
            end.to change(task_comment, :body).to("New body")
          end

          it "redirects to the task_comment" do
            task_comment = Fabricate(:task_comment, task: task)
            url =
              category_project_task_url(category, project, task,
                                        anchor: "comment-#{task_comment.id}")
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   task_id: task.to_param,
                                   id: task_comment.to_param,
                                   task_comment: new_attributes }
            expect(response).to redirect_to(url)
          end
        end

        context "with invalid params" do
          it "returns a success response ('edit' template)" do
            task_comment = Fabricate(:task_comment, task: task)
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   task_id: task.to_param,
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

        before { login(current_user) }

        context "for their own TaskComment" do
          context "with valid params" do
            it "updates the requested task_comment" do
              task_comment =
                Fabricate(:task_comment, task: task, user: current_user)
              expect do
                put :update, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       task_id: task.to_param,
                                       id: task_comment.to_param,
                                       task_comment: new_attributes }
                task_comment.reload
              end.to change(task_comment, :body).to("New body")
            end

            it "redirects to the task_comment" do
              task_comment = Fabricate(:task_comment, task: task,
                                                      user: current_user)
              anchor = "comment-#{task_comment.id}"
              url = category_project_task_url(category, project, task,
                                              anchor: anchor)
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              expect(response).to redirect_to(url)
            end
          end

          context "with invalid params" do
            it "returns a success response ('edit' template)" do
              task_comment =
                Fabricate(:task_comment, task: task, user: current_user)
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: invalid_attributes }
              expect(response).to be_successful
            end
          end
        end

        context "for someone else's TaskComment" do
          it "doesn't update the requested task_comment" do
            task_comment = Fabricate(:task_comment, task: task)
            expect do
              put :update, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     task_id: task.to_param,
                                     id: task_comment.to_param,
                                     task_comment: new_attributes }
              task_comment.reload
            end.not_to change(task_comment, :body)
          end

          it "should be unauthorized" do
            task_comment = Fabricate(:task_comment, task: task)
            put :update, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   task_id: task.to_param,
                                   id: task_comment.to_param,
                                   task_comment: new_attributes }
            expect_to_be_unauthorized(response)
          end
        end
      end
    end
  end

  describe "DELETE #destroy" do
    context "for an admin" do
      before { login(admin) }

      it "destroys the requested task_comment" do
        task_comment = Fabricate(:task_comment, task: task)
        expect do
          delete :destroy, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     task_id: task.to_param,
                                     id: task_comment.to_param }
        end.to change(TaskComment, :count).by(-1)
      end

      it "redirects to the task_comments list" do
        task_comment = Fabricate(:task_comment, task: task)
        delete :destroy, params: { category_id: category.to_param,
                                   project_id: project.to_param,
                                   task_id: task.to_param,
                                   id: task_comment.to_param }
        expect(response)
          .to redirect_to(category_project_task_url(category, project, task))
      end
    end

    %w[reviewer worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type}") }

        before { login(current_user) }

        it "doesn't destroy the requested task_comment" do
          task_comment = Fabricate(:task_comment, task: task)
          expect do
            delete :destroy, params: { category_id: category.to_param,
                                       project_id: project.to_param,
                                       task_id: task.to_param,
                                       id: task_comment.to_param }
          end.not_to change(TaskComment, :count)
        end

        it "should be unauthorized" do
          task_comment = Fabricate(:task_comment, task: task)
          delete :destroy, params: { category_id: category.to_param,
                                     project_id: project.to_param,
                                     task_id: task.to_param,
                                     id: task_comment.to_param }
          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
