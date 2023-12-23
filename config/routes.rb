Rails.application.routes.draw do
  root  'home#index'
  namespace :api, format: 'json' do
    namespace :v1 do
      resource :authentication, only: %i[create]
      resource :user, only: %i[update]
      resources :bookmarks, only: %i[index create update destroy] do
        collection do
          get 'check_duplicate'
        end
      end
      resources :folders, only: %i[index create update destroy]
    end
  end
end