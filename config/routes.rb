# frozen_string_literal: true

# For details on the DSL available within this file, see
# http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  resources :users
  resources :projects, only: :index
  resources :categories do
    resources :projects, except: :index
  end
  resources :issue_types, except: :show
  resources :task_types, except: :show
  root to: 'static#dashboard'
end
