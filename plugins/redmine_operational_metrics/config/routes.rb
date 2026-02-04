resources :operational_metrics do
  collection do
    get 'stats'
  end
end

resources :tactical_meetings, only: [:index, :new, :create]
resources :tactical_meeting_responses, only: [:index, :show, :new, :create]
