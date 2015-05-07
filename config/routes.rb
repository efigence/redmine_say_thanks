get 'thanks' => "thanks#new"

resources :thanks, only: [:new, :create] do
  collection do
    get 'given' => "thanks#given"
    get 'received' => "thanks#received"
    resources :rewards, only: :index, as: 'thanks_rewards'
  end
  member do
    put 'unroll' => "thanks#unroll"
  end
end

scope :thanks do
  scope :manager do
    scope ':group_id' do
      get '/' => "manager_thanks#index", as: 'manager_thanks'
      get 'stats' => "manager_thanks#stats", as: 'manager_thanks_stats'
      resources :rewards, controller: 'manager_rewards', only: [:index, :create], as: 'manager_rewards'
    end
  end
end
