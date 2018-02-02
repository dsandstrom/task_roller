# frozen_string_literal: true

# For details on the DSL available within this file, see
# http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  resources :users
  resources :projects, only: :index
  resources :categories do
    resources :projects, except: :index
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
