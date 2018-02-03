# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users
  resources :projects, only: :index
  resources :categories do
    resources :issues, only: :show
    resources :projects, except: :index do
      resources :issues, except: :index
    end
  end
  resources :roller_types, only: :index
  resources :issue_types, except: %i[index show]
  resources :task_types, except: %i[index show]
  resources :issues, only: :index
  patch '/reposition_issue_types/:id/:sort' => 'reposition_issue_types#update',
        as: :reposition_issue_type
  patch '/reposition_task_types/:id/:sort' => 'reposition_task_types#update',
        as: :reposition_task_type

  root to: 'static#dashboard'
end
