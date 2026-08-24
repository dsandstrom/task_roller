require "rails_helper"

RSpec.describe TaskTypeMigrationsController, type: :controller do
  describe "GET #new" do
    let(:task_type) { Fabricate(:task_type) }

    before { Fabricate(:task_type) }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "returns a success response" do
          get :new, params: { task_type_id: task_type.id }

          expect(response).to be_successful
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        it "should be unauthorized" do
          get :new, params: { task_type_id: task_type.id }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end

  describe "POST #create" do
    let(:task_type) { Fabricate(:task_type) }
    let(:new_task_type) { Fabricate(:task_type) }

    let(:valid_params) { { new_task_type_id: new_task_type.to_param } }
    let(:invalid_params) { { new_task_type_id: "" } }

    %w[admin reviewer].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }

        before { sign_in(current_user) }

        context "when current task_type has an task" do
          let!(:task) { Fabricate(:task, task_type: task_type) }

          context "when valid params" do
            it "updates the task's task_type" do
              expect do
                post :create, params: { task_type_id: task_type.id,
                                        task_type: valid_params }
                task.reload
              end.to change(task, :task_type_id).to(new_task_type.id)
            end

            it "redirects to issue_types index" do
              post :create, params: { task_type_id: task_type.id,
                                      task_type: valid_params }

              expect(response).to redirect_to(issue_types_path)
            end
          end

          context "when invalid params" do
            it "doesn't update the task" do
              expect do
                post :create, params: { task_type_id: task_type.id,
                                        task_type: invalid_params }
                task.reload
              end.not_to change(task, :task_type_id)
            end

            it "returns a success response" do
              post :create, params: { task_type_id: task_type.id,
                                      task_type: invalid_params }

              expect(response).to be_successful
            end
          end
        end
      end
    end

    %w[worker reporter].each do |employee_type|
      context "for a #{employee_type}" do
        let(:current_user) { Fabricate("user_#{employee_type.downcase}") }
        let!(:task) { Fabricate(:task, task_type: task_type) }

        before { sign_in(current_user) }

        it "doesn't update the task" do
          expect do
            post :create, params: { task_type_id: task_type.id,
                                    task_type: valid_params }
            task.reload
          end.not_to change(task, :task_type_id)
        end

        it "should be unauthorized" do
          post :create, params: { task_type_id: task_type.id,
                                  task_type: valid_params }

          expect_to_be_unauthorized(response)
        end
      end
    end
  end
end
