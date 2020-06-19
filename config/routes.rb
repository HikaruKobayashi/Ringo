Rails.application.routes.draw do
  resources :posts
  post '/callback' => 'line#callback'
end
