Rails.application.routes.draw do
  root "pages#home"
  resources :reservations, only: [:new, :create, :index] do
    get :slots, on: :collection
  end
end

