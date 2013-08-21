Dylome::Application.routes.draw do
  root 'songs#index'
  resources :songs
end
