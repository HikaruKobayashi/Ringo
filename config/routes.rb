Rails.application.routes.draw do
  resources :line
  post '/callback' => 'line#callback'
end
