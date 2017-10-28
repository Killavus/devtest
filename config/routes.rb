Rails.application.routes.draw do
  namespace :private do
    resources :countries, only: [] do
      resources :locations, only: [:index]
      resources :target_groups, only: [:index]
    end

    resource :target_evaluation, only: [:create]
  end

  resources :countries, only: [] do
    resources :locations, only: [:index]
    resources :target_groups, only: [:index]
  end
end
