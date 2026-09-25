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
        search_subscription_path(search_subscription)]]
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
