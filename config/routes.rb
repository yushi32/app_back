require 'sidekiq/web'

Rails.application.routes.draw do
  Sidekiq::Web.use(Rack::Auth::Basic) do |user_id, password|
    [user_id, password] == [ENV['SIDEKIQ_USER_ID'], ENV['SIDEKIQ_USER_PASSWORD']]
  end
  mount Sidekiq::Web, at: '/sidekiq'

  root  'home#index'
  namespace :api, format: 'json' do
    namespace :v1 do
      resource :authentication, only: %i[create]
      resource :user, only: %i[show update]
      resources :bookmarks, only: %i[index create update destroy] do
        collection do
          get 'check_duplicate'
        end
      end
      resources :folders, only: %i[index create update destroy]
      resource :notification, only: %i[create show]
    end
  end
end