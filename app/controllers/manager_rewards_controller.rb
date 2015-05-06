class ManagerRewardsController < BaseThanksController
  unloadable

  # before_action :permitted?
  # before_action :check_manageable_groups
  # before_action :find_and_authorize_group, only: [:management, :points]

  def create
    @reward = User.current.managed_rewards.new(reward_params)
    if @reward.save
      flash[:notice] = "Reward saved!"
      redirect_to '/' # temp
    else
      flash[:error] = @reward.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  private

  def reward_params
    params.require(:thanks_reward).permit(:user_id, :points, :title)
  end

end
