Rails.application.routes.draw do
  passwordless_for :users, at: "/auth", as: :auth

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
