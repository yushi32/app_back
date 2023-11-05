Rails.application.routes.draw do
  root  'home#index'
  namespace :api, format: 'json' do
    namespace :v1 do
      resource :authentication, only: %i[create]
      resources :bookmarks, only: %i[index create]
    end
  end
end