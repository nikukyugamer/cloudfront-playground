Rails.application.routes.draw do
  root 'home#index'

  get 'index', to: 'home#index'
  get 'eat_cookies', to: 'home#eat_cookies'
  get 'discard_cookies', to: 'home#discard_cookies'
  get 'fetch_images', to: 'home#fetch_images'
end
