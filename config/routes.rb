# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :users, only: nil do
    resources :issues, only: :index
    resources :tasks, only: :index
    resources :assignments, only: :index
  end

  get 'users/:user_id/employee_types/new' => 'employee_types#new',
      as: :new_user_employee_type
  get 'users/:user_id/employee_types/edit' => 'employee_types#edit',
      as: :edit_user_employee_type
  post 'users/:user_id/employee_types' => 'employee_types#create',
       as: :user_employee_types
  patch 'users/:user_id/employee_type' => 'employee_types#update',
        as: :user_employee_type
  delete 'users/:user_id/employee_type' => 'employee_types#destroy'

  get 'help' => 'help#index', as: :help
  get 'help/workflows' => 'help#workflows', as: :workflows_help
  get 'help/issue_types' => 'help#issue_types', as: :issue_types_help
  get 'help/user_types' => 'help#user_types', as: :user_types_help

  resources :categories do
    collection { get :archived }

    resources :tasks, only: :index
    resources :issues, only: :index
    resources :projects, except: %i[show edit update] do
      collection { get :archived }
    end
  end

  resources :projects, only: %i[show edit update] do
    resources :issues, only: %i[index new create destroy]
    resources :tasks, only: %i[index new create destroy]
  end

  resources :issues, only: %i[show edit update] do
    resources :issue_comments, except: :index
    resources :issue_subscriptions, only: %i[new create destroy]
    resources :resolutions, only: %i[new create destroy] do
      collection do
        post :approve
        post :disapprove
      end
    end
    resources :issue_notifications, only: nil do
      collection do
        delete :bulk_destroy
      end
    end
  end

  resources :tasks, only: %i[show edit update] do
    resources :task_assignees, only: %i[new create destroy]
    resources :task_comments, except: :index
    resources :task_subscriptions, only: %i[new create destroy]
    resources :progressions, only: %i[new create destroy] do
      member do
        patch :finish
      end
    end
    resources :reviews, only: %i[new edit create update destroy] do
      member do
        patch :approve
        patch :disapprove
      end
    end
    resources :task_notifications, only: nil do
      collection do
        delete :bulk_destroy
      end
    end
  end

  resources :subscriptions, only: :index

  resources :issue_notifications, only: :destroy
  resources :task_notifications, only: :destroy
  resources :issue_types, except: %i[show]
  resources :task_types, except: %i[index show]
  patch '/reposition_issue_types/:id/:sort' => 'reposition_issue_types#update',
        as: :reposition_issue_type
  patch '/reposition_task_types/:id/:sort' => 'reposition_task_types#update',
        as: :reposition_task_type

  resources :assignments, only: %i[edit update]

  get '/tasks/:task_id/issues/:id' => 'issues#show', as: :task_issue
  get '/issues/:issue_id/tasks' => 'tasks#index', as: :issue_tasks

  get 'search' => 'searches#new', as: :search
  get 'search/results' => 'searches#index', as: :search_results

  delete 'github_accounts' => 'github_accounts#destroy', as: :github_account

  %w[issue task].each do |roller|
    get "/#{roller}_connections/:source_id/new" => "#{roller}_connections#new",
        as: "new_#{roller}_connection"
    post "/#{roller}_connections/:source_id" => "#{roller}_connections#create",
         as: "#{roller}_connections"
    delete "/#{roller}_connections/:id" => "#{roller}_connections#destroy",
           as: "#{roller}_connection"

    get "/#{roller}_closures/:#{roller}_id/new" => "#{roller}_closures#new",
        as: "new_#{roller}_closure"
    post "/#{roller}_closures/:#{roller}_id" => "#{roller}_closures#create",
         as: "#{roller}_closures"
    delete "/#{roller}s/:#{roller}_id/closures/:id" =>
      "#{roller}_closures#destroy", as: "#{roller}_closure"

    get "/#{roller}_reopenings/:#{roller}_id/new" => "#{roller}_reopenings#new",
        as: "new_#{roller}_reopening"
    post "/#{roller}_reopenings/:#{roller}_id" => "#{roller}_reopenings#create",
         as: "#{roller}_reopenings"
    delete "/#{roller}s/:#{roller}_id/reopenings/:id" =>
      "#{roller}_reopenings#destroy", as: "#{roller}_reopening"

    get "#{roller}s/:#{roller}_id/move" => "move_#{roller}s#edit",
        as: "new_#{roller}_move"
    patch "#{roller}s/:#{roller}_id/move" => "move_#{roller}s#update",
          as: "move_#{roller}"
  end

  %w[issues tasks].each do |roller|
    get "/categories/:category_id/#{roller}_subscriptions/new" =>
      "category_#{roller}_subscriptions#new",
        as: "new_category_#{roller}_subscription"
    post "/categories/:category_id/#{roller}_subscriptions" =>
      "category_#{roller}_subscriptions#create",
         as: "category_#{roller}_subscriptions"
    delete "/categories/:category_id/#{roller}_subscriptions/:id" =>
      "category_#{roller}_subscriptions#destroy",
           as: "category_#{roller}_subscription"

    get "/projects/:project_id/#{roller}_subscriptions/new" =>
      "project_#{roller}_subscriptions#new",
        as: "new_project_#{roller}_subscription"
    post "/projects/:project_id/#{roller}_subscriptions" =>
      "project_#{roller}_subscriptions#create",
         as: "project_#{roller}_subscriptions"
    delete "/projects/:project_id/#{roller}_subscriptions/:id" =>
      "project_#{roller}_subscriptions#destroy",
           as: "project_#{roller}_subscription"
  end

  # https://github.com/heartcombo/devise/wiki/
  # How-To:-Allow-users-to-edit-their-password
  # FIXME: omniauth uses /auth/auth/
  devise_for :users,
             path: 'auth', skip: :registrations,
             controllers: { confirmations: 'users/confirmations',
                            omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'auth/sign_up' => 'users/registrations#new', as: :new_user_registration
    post 'auth' => 'users/registrations#create', as: :user_registrations
    delete 'auth' => 'users/registrations#destroy'

    get 'auth/edit' => 'users/registrations#edit', as: :edit_user_registration
    put 'auth' => 'users/registrations#update', as: :user_registration
  end

  namespace :api do
    namespace :v1 do
      post 'github' => 'webhooks#github'
    end
  end

  get '/sitemap' => 'static#sitemap', as: :sitemap
  get '/unauthorized' => 'static#unauthorized', as: :unauthorized
  root to: 'categories#index'
end
