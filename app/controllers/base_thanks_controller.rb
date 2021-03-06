class BaseThanksController < ApplicationController
  before_action :permitted?
  before_action :check_manageable_groups

  private

  def check_manageable_groups
    manageable_groups_ids = User.current.manageable_thanks_group_ids
    @manageable_groups = Group.where(id: manageable_groups_ids)
  end

  def permitted?
    deny_access unless User.current.can_access_thanks?
  end

  def find_and_authorize_group
    @group = Group.find(params[:group_id])
    deny_access unless @manageable_groups.include?(@group)
  end
end
