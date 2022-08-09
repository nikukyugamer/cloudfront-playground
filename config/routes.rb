Rails.application.routes.draw do
  root 'home#index'

  get 'index', to: 'home#index'
  get 'eat_cookies', to: 'home#eat_cookies'
  get 'discard_cookies', to: 'home#discard_cookies'
  get 'direct_image_link', to: 'home#direct_image_link'
end
