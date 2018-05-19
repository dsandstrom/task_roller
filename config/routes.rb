# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users
  resources :projects, only: :index
  resources :categories do
    resources :issues, only: %i[index show]
    resources :tasks, only: %i[index show]
    resources :projects, except: :index do
      resources :issues do
        resources :tasks, only: %i[new create]
      end
      resources :tasks
    end
  end
  resources :roller_types, only: :index
  resources :issue_types, except: %i[index show]
  resources :task_types, except: %i[index show]
  patch '/reposition_issue_types/:id/:sort' => 'reposition_issue_types#update',
        as: :reposition_issue_type
  patch '/reposition_task_types/:id/:sort' => 'reposition_task_types#update',
        as: :reposition_task_type

  root to: 'static#dashboard'
end
