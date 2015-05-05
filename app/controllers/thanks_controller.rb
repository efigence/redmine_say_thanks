class ThanksController < ApplicationController
  unloadable

  before_action :permitted?
  before_action :check_manageable_groups
  before_action :find_and_authorize_group, only: [:management, :points]

  def new
    @new_thanks = User.current.sent_thanks.new
  end

  def create
    @new_thanks = User.current.sent_thanks.new(thanks_params)

    if @new_thanks.save
      flash[:notice] = 'Thanks saved!'
      redirect_to given_thanks_path
    else
      flash[:error] = @new_thanks.errors.full_messages.to_sentence
      render :new
    end
  end

  def given
    @thanks = User.current.sent_thanks
  end

  def received
    @thanks = User.current.received_thanks
    @points = {
      total:    @thanks.where.not(status: 1).count,
      to_spend: @thanks.active.count,
      spent:    @thanks.rewarded.count
    }
  end

  def management
    @users = @group.users
    @thanks = Thanks.involving(@users.pluck(:id)).includes(:sender, :receiver)
    filter_params.each do |key, value|
      @thanks = @thanks.public_send(key, value) if value.present?
    end
  end

  def points
    @selectable_users = @group.users.select(:id, :firstname, :lastname)
    @users_with_points = @group.users.with_thanks_stats
    @users_with_points = @users_with_points.where(id: params[:user_id]) if params[:user_id]
  end

  def destroy
  end

  def unroll
    @thanks = Thanks.find(params[:id])
    @thanks.unrolled!
    flash[:notice] = 'Thanks unrolled!'
    redirect_to given_thanks_path
  end

  private

  def find_and_authorize_group
    @group = Group.find(params[:id])
    deny_access unless @manageable_groups.include?(@group)
  end

  def filter_params
    params.slice(:sent_by, :received_by, :status, :date_created)
  end

  def thanks_params
    params.require(:thanks).permit(:receiver_id)
  end

  def check_manageable_groups
    manageable_groups_ids = User.current.manageable_thanks_group_ids
    @manageable_groups = Group.where(id: manageable_groups_ids)
  end

  def permitted?
    deny_access unless User.current.can_access_thanks?
  end
end
