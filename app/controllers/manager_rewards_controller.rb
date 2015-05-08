class ManagerRewardsController < BaseThanksController
  unloadable

  before_action :find_and_authorize_group, only: :index

  def index
    @users = @group.users.includes(:received_rewards)
    @rewards = ThanksReward.where(user_id: @users.pluck(:id))

    filter_params.each do |key, value|
      @rewards = @rewards.public_send(key, value) if value.present?
    end

    @paginate, @rewards = paginate @rewards.order(created_at: :desc), per_page: 20
    @reward = User.current.managed_rewards.new
  end

  def create
    @reward = User.current.managed_rewards.new(reward_params)
    if @reward.save
      flash[:notice] = t('thanks.reward_assigned')
    else
      flash[:error] = @reward.errors.full_messages.to_sentence
    end
    redirect_to :back
  end

  private

  def filter_params
    params.slice(:received_by, :date_from, :date_to)
  end

  def reward_params
    params.require(:thanks_reward).permit(:user_id, :points, :title)
  end
end
