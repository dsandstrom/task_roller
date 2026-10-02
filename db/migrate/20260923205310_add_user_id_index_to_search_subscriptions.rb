class AddUserIdIndexToSearchSubscriptions < ActiveRecord::Migration[8.1]
  def change
    add_index :search_subscriptions, :user_id
    add_index :search_subscriptions,
              %i[user_id term issue_status task_status issue_type_id
                 task_type_id project_id category_id include_issues
                 include_tasks source_user_id],
              name: :index_search_subscriptions_on_user_id_and_parameters,
              unique: true
  end
end
