Dylome::Application.routes.draw do
  root 'songs#index'
  resources :songs, only: [:new, :create, :index, :show]
end
