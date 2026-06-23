Rails.application.routes.draw do
  passwordless_for :users, at: "/auth", as: :auth

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  namespace :admin do
    resources :teams
    resources :fixtures
  end

  root to: "fixtures#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
