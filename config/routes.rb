# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :users do
    resources :issues, only: :index
    resources :tasks, only: :index
  end

  resources :categories do
    resources :tasks, only: :index
    resources :issues, only: :index

    # TODO: only new, create
    resources :projects, except: :index
  end

  resources :projects, only: :index do
    resources :issues, only: %i[index new create]
    resources :tasks, only: %i[index new create]
  end

  resources :issues, only: %i[show edit update destroy] do
    resources :tasks, only: %i[new create]
    resources :issue_comments, except: %i[index show]
    resources :resolutions, only: %i[index new create destroy] do
      collection do
        post :approve
        post :disapprove
      end
    end

    member do
      patch :open
      patch :close
    end
  end

  resources :tasks, only: %i[show edit update destroy] do
    resources :task_comments, except: %i[index show]
    resources :progressions, except: :show do
      member do
        patch :finish
      end
    end
    resources :reviews, except: %i[show update] do
      member do
        patch :approve
        patch :disapprove
      end
    end

    member do
      patch :open
      patch :close
    end
  end

  resources :roller_types, only: :index
  resources :issue_types, except: %i[index show]
  resources :task_types, except: %i[index show]
  patch '/reposition_issue_types/:id/:sort' => 'reposition_issue_types#update',
        as: :reposition_issue_type
  patch '/reposition_task_types/:id/:sort' => 'reposition_task_types#update',
        as: :reposition_task_type

  resources :task_assignments, only: %i[edit update]

  %w[issue task].each do |roller|
    get "/#{roller}_connections/:source_id/new" => "#{roller}_connections#new",
        as: "new_#{roller}_connection"
    post "/#{roller}_connections/:source_id" => "#{roller}_connections#create",
         as: "#{roller}_connections"
    delete "/#{roller}_connections/:id" => "#{roller}_connections#destroy",
           as: "#{roller}_connection"
  end

  mount RollerAuthentication::Engine => '/auth'

  get '/unauthorized' => 'static#unauthorized', as: :unauthorized
  root to: 'static#dashboard'
end
