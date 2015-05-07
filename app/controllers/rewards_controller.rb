class RewardsController < BaseThanksController

  def index
    @rewards = User.current.received_rewards.includes(:manager)
    @paginate, @rewards = paginate @rewards.order(created_at: :desc), per_page: 20
  end
end
