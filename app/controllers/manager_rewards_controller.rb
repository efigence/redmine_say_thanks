class ManagerRewardsController < BaseThanksController
  unloadable

  before_action :find_and_authorize_group, only: :index

  def index
    @users = @group.users.includes(:received_rewards)
    @rewards = ThanksReward.where(user_id: @users.pluck(:id))

    @rewards = @rewards.where(user_id: params[:received_by]) if params[:received_by]

    @paginate, @rewards = paginate @rewards.order(created_at: :desc), per_page: 20

    @reward = User.current.managed_rewards.new
  end

  def create
    @reward = User.current.managed_rewards.new(reward_params)
    if @reward.save
      flash[:notice] = "Reward saved!"
    else
      flash[:error] = @reward.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  private

  def reward_params
    params.require(:thanks_reward).permit(:user_id, :points, :title)
  end

end
