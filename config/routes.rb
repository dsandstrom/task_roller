# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :users do
    resources :issues, only: :index
    resources :tasks, only: :index
    resources :assignments, only: :index
  end

  resources :categories, except: :show do
    resources :tasks, only: :index
    resources :issues, only: :index

    resources :projects, except: %i[show edit update]
  end

  resources :projects, only: %i[show edit update] do
    resources :issues, only: %i[index new create]
    resources :tasks, only: %i[index new create]
  end

  resources :issues, except: %i[index new create] do
    resources :issue_comments, except: %i[index show]
    resources :issue_subscriptions, only: %i[new create destroy]
    resources :resolutions, only: %i[index new create destroy] do
      collection do
        post :approve
        post :disapprove
      end
    end
  end

  resources :tasks, only: %i[show edit update destroy] do
    resources :task_comments, except: %i[index show]
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
  end

  resources :issue_types, except: %i[show]
  resources :task_types, except: %i[index show]
  patch '/reposition_issue_types/:id/:sort' => 'reposition_issue_types#update',
        as: :reposition_issue_type
  patch '/reposition_task_types/:id/:sort' => 'reposition_task_types#update',
        as: :reposition_task_type

  resources :assignments, only: %i[edit update]
  resources :task_subscriptions, only: :index
  resources :issue_subscriptions, only: :index

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
    delete "/#{roller}s/:#{roller}_id/closures/:id" => "#{roller}_closures#destroy",
           as: "#{roller}_closure"

    get "/#{roller}_reopenings/:#{roller}_id/new" => "#{roller}_reopenings#new",
        as: "new_#{roller}_reopening"
    post "/#{roller}_reopenings/:#{roller}_id" => "#{roller}_reopenings#create",
         as: "#{roller}_reopenings"
    delete "/#{roller}_reopenings/:id" => "#{roller}_reopenings#destroy",
           as: "#{roller}_reopening"
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

  mount RollerAuthentication::Engine => '/auth'

  get '/unauthorized' => 'static#unauthorized', as: :unauthorized
  root to: 'subscriptions#index'
end
