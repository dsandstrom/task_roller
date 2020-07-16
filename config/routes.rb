# frozen_string_literal: true

Rails.application.routes.draw do # rubocop:disable Metrics/BlockLength
  resources :issue_comments
  resources :users
  resources :projects, only: :index
  resources :categories do
    resources :tasks, only: %i[index]
    resources :issues, only: %i[index]

    resources :projects, except: :index do
      resources :issues do
        resources :tasks, only: %i[new create]
        resources :issue_comments, except: %i[index show]
      end

      resources :tasks do
        resources :task_comments, except: %i[index show]
      end
    end
  end

  resources :tasks, only: nil do
    member do
      patch :open
      patch :close
    end
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
  end

  resources :issues, only: nil do
    member do
      patch :open
      patch :close
    end
    resources :resolutions, except: %i[show update] do
      collection do
        post :approve
        post :disapprove
      end
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

  root to: 'static#dashboard'
end
