Rails.application.routes.draw do
  get 'bs', :to => 'bs#index'

  namespace :bs do
    resources :assets do
      member do
        post 'change_status'
      end
    end

    resources :investments
  end

end
