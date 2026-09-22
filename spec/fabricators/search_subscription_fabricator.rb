Fabricator(:search_subscription) do
  user
  term { 'search term' }
end

Fabricator(:inactive_search_subscription, from: :search_subscription) do
  active false
end

Fabricator(:issues_search_subscription, from: :search_subscription) do
  include_issues true
  include_tasks false
end

Fabricator(:tasks_search_subscription, from: :search_subscription) do
  include_issues false
  include_tasks true
end
