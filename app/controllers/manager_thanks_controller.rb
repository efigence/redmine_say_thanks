class ManagerThanksController < BaseThanksController

  before_action :find_and_authorize_group

  def index
    @users = @group.users
    @thanks = Thanks.involving(@users.pluck(:id)).includes(:sender, :receiver)
    filter_params.each do |key, value|
      @thanks = @thanks.public_send(key, value) if value.present?
    end

    @paginate, @thanks = paginate @thanks.order(created_at: :desc), per_page: 20
  end

  def stats
    @selectable_users = @group.users.select(:id, :firstname, :lastname)
    @users_with_points = @group.users.with_thanks_stats
    @users_with_points = @users_with_points.where(id: params[:received_by]) if params[:received_by]

    @reward = User.current.managed_rewards.new
  end

  private

  def filter_params
    params.slice(:sent_by, :received_by, :status, :date_created)
  end

  def find_and_authorize_group
    @group = Group.find(params[:group_id])
    deny_access unless @manageable_groups.include?(@group)
  end
end
