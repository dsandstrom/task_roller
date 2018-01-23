# frozen_string_literal: true

# For details on the DSL available within this file, see
# http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  root to: 'static#dashboard'

  resources :users
  resources :categories do
    resources :projects
  end
end
