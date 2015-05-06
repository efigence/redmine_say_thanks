resources :thanks, only: [:new, :create] do
  collection do
    get 'given' => "thanks#given"
    get 'received' => "thanks#received"
    get 'rewards' => "thanks#rewards"

    get 'manager/:id' => "thanks#management", as: 'manager'
    post 'manager/rewards' => 'thanks_rewards#create', as: 'post_rewards'
    get 'points/:id' => "thanks#points", as: 'points'
  end
  member do
    put 'unroll' => "thanks#unroll"
  end
end

get 'thanks' => "thanks#new"
