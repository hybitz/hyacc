Rails.application.routes.draw do
  get 'bs', :to => 'bs#index'

  namespace :bs do
    resources :assets

    resources :investments do
      collection do
        get 'not_related'
        get 'relate'
      end
    end
  end

end
