module SubscriptionsHelper
  def search_subscription_header(search_subscription)
    enable_page_title 'Saved Search'

    content_for :header do
      concat breadcrumbs(search_subscription_pages(search_subscription))
      concat search_subscription_columns(search_subscription)
    end
  end

  def subscriptions_header(heading, page_title = heading)
    enable_page_title page_title

    content_for :header do
      concat content_tag :h1, heading
      concat subscriptions_nav
    end
  end

  private

    def search_subscription_pages(search_subscription)
      [['Saved Searches', search_subscriptions_path],
       [search_subscription.title,
        search_subscription_path_to_source(search_subscription)]]
    end

    def search_subscription_path_to_source(search_subscription)
      filters = search_subscription_filters(search_subscription)

      if search_subscription.source_user
        if search_subscription.include_issues
          user_issues_path(search_subscription.source_user, filters)
        else
          user_tasks_path(search_subscription.source_user, filters)
        end
      elsif search_subscription.category
        if search_subscription.include_issues && search_subscription.include_tasks
          category_path(search_subscription.category, filters)
        elsif search_subscription.include_issues
          category_issues_path(search_subscription.category, filters)
        else
          category_tasks_path(search_subscription.category, filters)
        end
      elsif search_subscription.project
        if search_subscription.include_issues && search_subscription.include_tasks
          project_path(search_subscription.project, filters)
        elsif search_subscription.include_issues
          project_issues_path(search_subscription.project, filters)
        else
          project_tasks_path(search_subscription.project, filters)
        end
      else
        search_results_path(filters)
      end
    end

    def search_subscription_filters(search_subscription)
      filters = search_subscription.filter_params
      filters.reverse_merge!(order: 'updated,desc')
      return filters if search_subscription.include_issues &&
                        search_subscription.include_tasks

      if search_subscription.include_issues
        filters.reverse_merge!(type: 'issues', issue_status: 'all', issue_type_id: 'all')
      else
        filters.reverse_merge!(type: 'tasks', task_status: 'all', task_type_id: 'all')
      end

      filters
    end

    def search_subscription_first_column
      content_tag :div, class: 'first-column' do
        content_tag :h1, 'Current Results'
      end
    end

    def search_subscription_second_column(search_subscription)
      content_tag :div, class: 'second-column button-column' do
        render 'search_subscriptions/toggle_form',
               search_subscription: search_subscription
      end
    end

    def search_subscription_columns(search_subscription)
      content_tag(
        :div,
        safe_join([search_subscription_first_column,
                   search_subscription_second_column(search_subscription)]),
        class: 'columns'
      )
    end

    def subscriptions_nav
      content_tag :p, class: 'page-nav subscriptions-nav' do
        safe_join(navitize([['Subscriptions', subscriptions_path],
                            ['Saved Searches', search_subscriptions_path]]))
      end
    end
end
