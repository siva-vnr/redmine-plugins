resources :operational_metrics do
  collection do
    get 'stats'
  end
end

resources :holidays, only: [:index, :create, :destroy]

namespace :api do
  resources :operational_metrics
end

resources :tactical_meetings, only: [:index, :new, :create]
resources :tactical_meeting_responses, only: [:index, :show, :new, :create, :edit, :update] do
  resource :review, only: [:new, :create, :edit, :update], controller: 'tactical_meeting_reviews'
end

resources :kras, only: [:index, :edit, :update], param: :role
