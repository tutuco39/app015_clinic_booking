Rails.application.routes.draw do
  root "reservations#new"
  resources :reservations, only: [:new, :create, :index] do
    get :slots, on: :collection # /reservations/slots?date=YYYY-MM-DD
  end
end

