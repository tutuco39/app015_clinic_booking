Rails.application.routes.draw do
  # 開発環境でのみ有効
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # 既存のルーティング
  root "pages#home"
  resources :reservations, only: [:new, :create, :index] do
    get :slots, on: :collection
  end
end

