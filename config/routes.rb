Rails.application.routes.draw do
  get 'top/index'
  get 'top/latest'
  get 'top/clear'
  post 'top/put_stone'
  root 'top#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
