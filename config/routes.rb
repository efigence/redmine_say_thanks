resources :thanks, only: [:new, :create, :destroy] do
  collection do
    get 'given' => "thanks#given"
    get 'received' => "thanks#received"
    get 'manager/:id' => "thanks#management", as: 'manager'
    get 'points/:id' => "thanks#points", as: 'points'
  end
  member do
    put 'unroll' => "thanks#unroll"
  end
end

get 'thanks' => "thanks#new"
