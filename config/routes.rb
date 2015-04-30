resources :thanks, only: [:new, :create, :destroy] do
  collection do
    get 'given' => "thanks#given"
    get 'received' => "thanks#received"
  end
end

get 'thanks' => "thanks#new"
