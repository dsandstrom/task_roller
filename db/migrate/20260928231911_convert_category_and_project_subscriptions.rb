class ConvertCategoryAndProjectSubscriptions < ActiveRecord::Migration[8.1]
  def change
    CategoryIssuesSubscription.all.each do |subscription|
      subscription.user.search_subscriptions.create(
        category: subscription.category,
        include_tasks: false
      )
    end

    CategoryTasksSubscription.all.each do |subscription|
      subscription.user.search_subscriptions.create(
        category: subscription.category,
        include_issues: false
      )
    end

    ProjectIssuesSubscription.all.each do |subscription|
      subscription.user.search_subscriptions.create(
        project: subscription.project,
        include_tasks: false
      )
    end

    ProjectTasksSubscription.all.each do |subscription|
      subscription.user.search_subscriptions.create(
        project: subscription.project,
        include_issues: false
      )
    end
  end
end
