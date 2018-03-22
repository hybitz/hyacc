Rails.application.routes.draw do
  get 'bs', :to => 'bs#index'

  namespace :bs do
    resources :assets
  end
end
